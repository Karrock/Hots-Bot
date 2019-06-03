# This bot has various commands that show off CommandBot.

require 'bundler/setup'
require 'rubygems'
require 'discordrb'
require 'open-uri'
require 'dotenv'
require 'nokogiri'
require 'pp'
require 'mechanize'

# instantiate the token in .env file
Dotenv.load
bot_token = ENV['bot_token']

require_relative 'lib/hots_parser'
require_relative 'lib/icy_urls'

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
bot = Discordrb::Commands::CommandBot.new token: bot_token, prefix: '~', help_command: true

bot.command(:hots, hots: 1) do |event, hots|
  if !hots
    event.channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'KooPa')
      embed.title = 'Hi ' + event.user.name
      embed.description = '**Tip : You can add parameters to this command such as the hero name you want.**'
      embed.colour = 0x97d352
      embed.timestamp = Time.new
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: IcyUrls.new.logo_url)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Prowdly powered in ruby')
      embed.add_field(
        name: 'Here is base url of the website.',
        value: IcyUrls.new.to_s,
        inline: false
      )
    end
  else
    hots = hots.downcase

    build = HotsParser.new.parse(hots)

    # build the response
    event.channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'KooPa')
      embed.title = "Hi #{event.user.name} here is your build for #{hots.upcase} have fun :"
      embed.description = IcyUrls.new.build_url(hots)
      embed.colour = 0x97d352
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: HotsParser.new.getHeroPicture(hots))
      embed.timestamp = Time.new
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: IcyUrls.new.logo_url)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Prowdly powered in ruby')

      embed.add_field(
        name: 'And here is the talents page :',
        value: IcyUrls.new.talents_url(hots),
        inline: false
      )
      build.each do |talent_array|
        embed.add_field(
          name: "__**Level #{talent_array[0]} :**__",
          value: talent_array[1].join("\n"),
          inline: true
        )
      end
    end
  end
end

### WIP need to check why bot couldn't talk
bot.command(:rick) do |event|
  channel = event.user.voice_channel
  next "You're not in any voice channel!" unless channel
  bot.voice_connect(channel)
  event << "Connected to voice channel: #{channel.name}"

  voice_bot = event.voice
  voice_bot.play_io('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
  # voice_bot.play_file('sources/audio/music.mp3')
  bot.voice_destroy(channel)
end


bot.command(:dick) do |event|
  agent = Mechanize.new
  link = 'https://source.unsplash.com/random/featured/?Dick'
  agent.get(link).save "pic.png" 
  event.send_file(File.open('pic.png', 'r'), caption: "Hey mais range moi ça " + event.user.name + "!" )
  sleep(5)
  event File.delete("pic.png")
end

bot.command(:food) do |event|
  agent = Mechanize.new
  link = 'https://source.unsplash.com/random/featured/?Food,Plate'
  agent.get(link).save "pic.png" 
  event.send_file(File.open('pic.png', 'r'), caption: "Voiçi votre repas " + event.user.name + ".")
  sleep(5)
  event File.delete("pic.png")
end

bot.command(:kick) do |event|
  channel = event.user.voice_channel
  bot.voice_destroy(channel) if channel
end

bot.run
