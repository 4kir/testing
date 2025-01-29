# frozen_string_literal: true

require 'nokogiri'
require 'prawn'

COMPONENTS = ['Computer Name', 'Motherboard Name', 'System Memory', 'CPU Type', 'Video Adapter', 'Disk Drive'].freeze

font_path = 'data/fonts/DejaVuSans.ttf'
file_path = File.join(__dir__, '/data/input/report.htm')
htm_file = File.read(file_path)

# Парсим htm-документ
doc = Nokogiri::HTML(htm_file)

lines = []
# Достаем элементы из html-дерева
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

# Формируем PDF-документ
Prawn::Document.generate('data/output/output.pdf') do |pdf|
  # Подключаем шрифт с поддержкой кириллицы
  pdf.font font_path

  # Добавляем текст на кириллице
  pdf.text 'Карточка сотрудника', size: 20, align: :center
  pdf.move_down 50
  pdf.text 'Технические характеристики:', size: 16

  # Добавляем строки в PDF
  lines.each do |line|
    pdf.text line
  end

  pdf.stroke_horizontal_rule
  pdf.pad(2) { pdf.text 'Text padded both before and after.' }
  pdf.stroke_horizontal_rule

  pdf.bounding_box([0, pdf.cursor], width: 520) do
    pdf.pad(2) { pdf.text 'Text written inside the float block 1.' }
    pdf.stroke_bounds
  end
  pdf.bounding_box([0, pdf.cursor], width: 500) do
    pdf.pad(2) { pdf.text 'Text written inside the float block 2.' }
    pdf.stroke_bounds
  end
  pdf.bounding_box([0, pdf.cursor], width: 500) do
    pdf.pad(2) { pdf.text 'Text written inside the float block 3.' }
    pdf.stroke_bounds
  end
  pdf.bounding_box([0, pdf.cursor], width: 500) do
    pdf.pad(2) { pdf.text 'Text written inside the float block 4.' }
    pdf.stroke_bounds
  end

  pdf.float do
    pdf.move_down 30
    pdf.bounding_box([0, pdf.cursor], width: 500) do
      pdf.pad(2) { pdf.text 'Text written inside the float block.' }
      pdf.stroke_bounds
    end
    pdf.bounding_box([0, pdf.cursor], width: 500) do
      pdf.pad(2) { pdf.text 'Text written inside the float block.' }
      pdf.stroke_bounds
    end
  end
end

puts 'Файл PDF создан'
