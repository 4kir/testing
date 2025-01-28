# frozen_string_literal: true

require 'nokogiri'
require 'prawn'

font_path = 'DejaVuSans.ttf'
file_path = File.join(__dir__, '/data/report.htm')
htm_file = File.read(file_path)

doc = Nokogiri::HTML(htm_file)

COMPONENTS = ['Computer Name', 'Motherboard Name', 'System Memory', 'CPU Type', 'Video Adapter', 'Disk Drive'].freeze

lines = []
doc.css('table').each do |row|
  next unless row.css('a').text.include?('Summary')

  COMPONENTS.map do |component|
    row.next.css('tr').each do |node|
      next unless node.text.include?(component)

      lines << node.text.gsub(component, '')[2..].strip
      break if component == 'Video Adapter'
    end
  end
end

Prawn::Document.generate('output.pdf') do |pdf|
  # Подключаем шрифт с поддержкой кириллицы
  pdf.font font_path

  # Добавляем текст на кириллице
  pdf.text 'Пример текста на кириллице: Привет, мир!', size: 20, align: :center
  pdf.move_down 50
  pdf.text "Этот PDF документ использует шрифт #{font_path}", size: 16

  # Добавляем строки в PDF
  lines.each do |line|
    pdf.text line
  end
end
