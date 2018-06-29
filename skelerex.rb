# This bot has various commands that show off CommandBot.

require 'bundler/setup'
require 'rubygems'
require 'discordrb'
require 'open-uri'
require 'dotenv'
require 'nokogiri'
require 'rubocop'
require 'pp'

# instantiate the token in .env file
Dotenv.load
bot_token = ENV['bot_token']

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
bot = Discordrb::Commands::CommandBot.new token: bot_token, prefix: '~', help_command: true

bot.command(:hots, hots: 1) do |event, hots|
  icy_base = 'https://www.icy-veins.com/heroes'

  if hots
    hots = hots.downcase
    icy_guide = icy_base + "/#{hots}-build-guide"
    icy_talents = icy_base + "/#{hots}-talents"

    doc = Nokogiri::HTML(open(icy_talents))
    hero_picture = 'http:' + doc.css('div.page_content div.float_left img').attr('src').text
    talent_table = doc.css('table.talent_table')

    # get data from website
    build = []
    talent_table.css('tr').each do |row|
      level = row.css('td.talent_unlock').text
      talent = []
      row.css('td.talent_list').each do |talent_container|
        ### When discordrb will suport multiple embed images replace marker by images
        talent_container.css('span.talent_container').map do |node|
          talent << node.css('img').attr('alt').text + ' : ' + node.css('span.talent_marker').text
          # talent << 'http:' + node.css('img').attr('src').text.gsub("large","small")
        end
      end
      build << [
        level,
        talent
      ]
    end

    # pp build

    # build.each do |talent_array|
    #   talent_array.each do |_talent_detail|
    #     if  _talent_detail != ''
    #       if _talent_detail.class != Array
    #         event << "__**Level #{_talent_detail} :**__"
    #       else
    #         _talent_detail.each do |talent|
    #           event << talent
    #         end
    #         event << ''
    #       end
    #     end
    #   end
    # end

    # build the response
    event.channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'KooPa')
      embed.title = 'Hi ' + event.user.name + ' here is your build for ' + hots.upcase + ' have fun :'
      embed.description = icy_guide
      embed.colour = 0x97d352
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: hero_picture)
      embed.timestamp = Time.new
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: 'https://static.icy-veins.com/images/common/icy-veins-icon-social.png')
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Prowdly powered in ruby')

      embed.add_field(
        name: 'And here is the talents page :',
        value: icy_talents,
        inline: false
      )
    end

  else
    event.channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'KooPa')
      embed.title = 'Hi ' + event.user.name
      embed.description = '**Tip : You can add parameters to this command such as the hero name you want.**'
      embed.colour = 0x97d352
      embed.timestamp = Time.new
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: 'https://static.icy-veins.com/images/common/icy-veins-icon-social.png')
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Prowdly powered in ruby')
      embed.add_field(
        name: 'Here is base url of the website.',
        value: icy_base,
        inline: false
      )
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
  # voice_bot.play_io('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
  voice_bot.play_file('sources/audio/music.mp3')
  bot.voice_destroy(channel)
end

bot.command(:kick) do |event|
  channel = event.user.voice_channel
  bot.voice_destroy(channel) if channel
end

bot.run
