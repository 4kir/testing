# frozen_string_literal: true

require 'nokogiri'
require 'prawn'

font_path = 'DejaVuSans.ttf'
file_path = File.join(__dir__, '/data/report_rus.htm')
htm_file = File.read(file_path).encode('UTF-8', 'Windows-1251')

doc = Nokogiri::HTML(htm_file)

COMPONENTS = ['Имя компьютера', 'Системная плата', 'Системная память', 'Тип ЦП', 'Видеоадаптер', 'Дисковый накопитель'].freeze

lines = []
doc.css('table').each do |row|
  next unless row.css('a').text.include?('Суммарная информация')

  COMPONENTS.map do |component|
    row.next.css('tr').each do |node|
      next unless node.text.include?(component)

      p node.text.gsub(component, '')[2..].strip
      break if component == 'Видеоадаптер'
    end
  end
end

Prawn::Document.generate('output.pdf') do |pdf|
  # Подключаем шрифт с поддержкой кириллицы
  pdf.font font_path

  # Добавляем текст на кириллице
  pdf.text 'Пример текста на кириллице: Привет, мир!', size: 20, align: :right
  pdf.move_down 50
  pdf.text "Этот PDF документ использует шрифт #{font_path}
  ", size: 16

  # Добавляем строки в PDF
  lines.each do |line|
    pdf.text line
  end
end
