# Hold interpolations to use with paperclip interpolation system for name attachment when saved
#

Paperclip.interpolates :editor do |attachment, style|
  attachment.instance.name.parameterize.underscore.to_s
end