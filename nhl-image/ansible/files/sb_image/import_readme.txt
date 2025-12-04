If you place a zip file called configs.zip in this folder, on first boot and the first time you ssh to the scoreboard, 
you will be asked if you want to import the files contained in the configs.zip.

The following files need to be placed in the configs.zip:

/home/pi/nhl-led-scoreboard/config/config.json
/home/pi/sbtools/testMatrix.sh
/etc/supervisor/conf.d/scoreboard.conf

You can use the NLS Control Hub Utilities page to generate the configs.zip file