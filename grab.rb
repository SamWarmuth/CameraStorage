require 'httparty'
require 'FileUtils'

def download_images_and_create_video(count, delay)
  count.times do |index|
    puts index
    auth = {username: "grab", password: "grab"}
    response = HTTParty.get('http://192.168.1.70/image.jpg', basic_auth: auth)
    jpeg = response.parsed_response
    path = "tmp/image-#{(Time.now.to_f * 1000).to_i}.jpg"
    File.open(path, "wb") do |f|
      f.write jpeg
    end
    sleep(delay)
  end

  video_stamp = (Time.now.to_f * 1000).to_i
  directory = "videos/processing-#{video_stamp}"
  system 'mkdir', '-p', directory

  paths = Dir["tmp/image*"]
  paths.each_with_index do |path, index|
    #FileUtils.cp(path, "images")
    FileUtils.mv(path, "#{directory}/image-#{index}.jpg")
  end
  #Thread.new do
    files = Dir["#{directory}/image*"]
    out_path = "videos/video-#{video_stamp}.mp4"
    result = system("ffmpeg -framerate 5 -i #{directory}/image-%d.jpg -vf scale=640:-1,format=yuv420p -vcodec libx264 -preset slow -crf 32 #{out_path}")
    FileUtils.rm_rf(directory)
  #end
end

loop do
  download_images_and_create_video(320, 0.15)
end



#LOAD RAW VIDEO! ffmpeg -r 5 -f mjpeg -i http://grab:grab@192.168.1.70/mjpeg.cgi -vcodec copy  outfile.mp4


#ffmpeg -r 5 -f mjpeg -i http://grab:grab@192.168.1.70/mjpeg.cgi -f segment -segment_time 10 -preset slow -crf 35 videos/stream%05d.ts

#ffmpeg -i http://grab:grab@192.168.1.70/mjpeg.cgi -re -g 250 -keyint_min 25 -bf 0 -me_range 16 -sc_threshold 40 -cmp 256 -coder 0 -trellis 0 -subq 6 -refs 5 -r 25 -c:a libfaac -ab:a 256k -async 1 -ac:a 2 -c:v libx264 -profile baseline -s:v 1280x720 -b:v 3000k -aspect:v 16:9 -map 0 -ar 44100 -vbsf h264_mp4toannexb -flags -global_header -f segment -segment_time 10 -segment_list_flags +live -segment_list_size 5 -segment_list_type m3u8 -segment_list test.m3u8 -segment_format mpegts stream%05d.ts
