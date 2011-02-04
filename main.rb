require 'config/boot'

Boot.load(:application) #Boot loads the requested application into Sockit.command 
Sockit.command.start

