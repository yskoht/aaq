# frozen_string_literal: true

require 'tempfile'

def remove_escseq(code)
  code.gsub(/\e.*?m/, '')
end

RSpec.describe AAQ do
  let(:test_img) { 'spec/img/test.png' }
  let(:syntax_ok) { "Syntax OK\n" }
  let(:escape_sequence) { /\e.*?m/ }

  it 'has a version number' do
    expect(AAQ::VERSION).not_to be nil
  end

  context 'default unit_horizontal and unit vertical' do
    let(:aaq) { AAQ::AAQ.new(test_img) }

    it 'generates valid code' do
      Tempfile.create do |t|
        t.write(aaq.convert.code)
        t.close

        open(t.path) do |f|
          expect(f.read).not_to be_empty
        end

        puts `ruby #{t.path}`

        res = `ruby -c #{t.path}`
        expect(res).to eq syntax_ok
      end
    end

    it 'generates the same code with code.to_s and its eval' do
      code_s = aaq.convert.to_s

      Tempfile.create do |t|
        t.write(code_s)
        t.close

        code_e = `ruby #{t.path}`
        expect(code_e).to eq code_s
      end
    end

    it 'generates the same code with code.to_s and colorful code' do
      code_s = aaq.convert.to_s

      Tempfile.create do |t|
        t.write(code_s)
        t.close

        code_c = `ruby #{t.path} --color`
        code_cr = remove_escseq(code_c)
        expect(code_cr).to eq code_s
      end
    end

    it 'generates the same code with colorful code and its eval' do
      Tempfile.create do |t1|
        t1.write(aaq.convert.to_s)
        t1.close

        code_c = `ruby #{t1.path} --color`
        code_cr = remove_escseq(code_c)

        Tempfile.create do |t2|
          t2.write(code_cr)
          t2.close

          code_e = `ruby #{t2.path} --color`
          code_er = remove_escseq(code_e)

          expect(code_e).to eq code_c
          expect(code_er).to eq code_cr
        end
      end
    end

    it 'generates colorful code when --color option' do
      Tempfile.create do |t|
        t.write(aaq.convert.to_s)
        t.close

        puts `ruby #{t.path} --color`
      end
    end

    it 'default unit_horizontal = 6 and unit_vertical = 14' do
      expect(aaq.unit_horizontal).to eq 6
      expect(aaq.unit_vertical).to eq 14
    end
  end

  context 'customize unit_horizontal and unit vertical' do
    it 'unit_horizontal and unit_vertical are set' do
      aaq = AAQ::AAQ.new(test_img, options: { unit_horizontal: 4, unit_vertical: 8 })
      expect(aaq.unit_horizontal).to eq 4
      expect(aaq.unit_vertical).to eq 8

      Tempfile.create do |t|
        t.write(aaq.convert.to_s)
        t.close

        puts `ruby #{t.path} --color`
      end
    end
  end
end
