#!/usr/bin/ruby

require 'rubygems'
require 'RMagick'
include Magick

#hopkins 671-2345

dir = ARGV[0]
f_name = ARGV[1]
w_option = ARGV[2]

if ARGV.empty?
  puts 'ruby single-folder-watermark.rb [directory] [new file name] [watermark yes/no] [max image width]'
  exit
end

c = 1

def filesize img_path
    i = 5
    while File.size(img_path) > 499000
        imgq = Magick::ImageList.new(img_path)
        imgq.write(img_path) do
            self.format = 'JPEG'
            self.quality = 100 - i
        end 
        i += 5
    end
end

begin

dir_s = dir.chomp.to_s
f_name_s = f_name.chomp.to_s

dir_sorted = Dir.entries(dir_s).sort_by { |a| b = File.join(ARGV[0], a); File.stat(b).mtime }
dir_sorted.each do |pic, index|

    if File.extname(pic) == '.jpg' || File.extname(pic) == '.JPG' || File.extname(pic) == '.jpeg' || File.extname(pic) == '.png' and !(pic =='.' || pic == '..' || pic =~ /thumb/i )

        if w_option == 'no'
            if !Dir.exist?(dir_s + '\Resized')
                Dir.chdir(dir_s)
                (Dir.mkdir 'Resized')
                puts Dir.pwd
            end
        else
            if !Dir.exist?(dir_s + '\Watermarked')
                Dir.chdir(dir_s)
                (Dir.mkdir 'Watermarked')
                puts Dir.pwd
            end
        end

        printf 'editing image %s' % pic

        img = Magick::ImageList.new(dir_s + '\\' + pic)

        if img.columns > 1080
            img.density = '72'
            resized_img = img.resize_to_fit!(1080)

        else
            resized_img = img
        end

        ext = File.extname(pic)

        if w_option != "no"
            printf ' | adding watermark'

            mark = Magick::Image.new(resized_img.columns, resized_img.rows) {self.background_color = "transparent"}
            gc = Magick::Draw.new

            gc.annotate(mark, 0, 0, 0, -5, "\u00A9 RE/MAX 1st Choice | Belize | 523-3666") do
                gc.gravity = Magick::CenterGravity
                if resized_img.rows.to_i > resized_img.columns.to_i
                    font_size = resized_img.rows / 33.333333333
                else
                    font_size = resized_img.columns / 33.333333333
                end
                gc.pointsize = font_size.round
                gc.font_family = "Arial"
                gc.fill = "White"
                gc.stroke = "transparent"
                gc.font_style = NormalStyle
                gc.font_weight = 600
                gc.text_antialias = false
            end

            if resized_img.rows.to_i > resized_img.columns.to_i
                mark = mark.rotate(-90)
            end

            img_save_path = dir_s + "/Watermarked/" + f_name_s + "-" + c.to_s + '.jpg'

            img2 = resized_img.watermark(mark, 0.2, 0.2, Magick::CenterGravity)
            img2.strip!
            img2.write img_save_path

            filesize img_save_path

            puts ""

            mark.destroy!
            img2.destroy!
        else
            printf ' | resizing'

            resize_img_path = dir_s + "/Resized/" + f_name_s + "-" + c.to_s + '.jpg'
            
            resized_img.write resize_img_path
            filesize resize_img_path
            
            puts ""
        end    

        c += 1

    end
end
# rescue => e
#     puts e
end