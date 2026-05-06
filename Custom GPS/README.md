# Custom GPS Independent Project

This project was simple; I wanted a portable GPS in the smallest form factor I could produce. 

https://github.com/user-attachments/assets/7a307a40-54e3-43fe-a0f3-bad07214b9ce

I wanted specifically to work with AdaFruit's Featherwings PCBs and circuit python for this project. I designed a 3D-printable casing for it with cutouts for the screen, buttons, and a charging port. The screen is press-fit into the case. Several attempts were required to get the press-fit clearances just right. 

![GPS Internals](Images/GPS%20Internals.png)

The GPS code is largely based off of AdaFruit's beginner code for their GPS Featherwing, but modified to suit my purposes. The operational loops which check to see if any of the three buttons are pressed is entirely my creation, as are the screen updates. 

The uppermost button is a reset button. Of the three aligned buttons, the top button temporarily displays the last GPS fix. The middle button continuously updates the stored GPS coordinates and displays them. The bottom button updates the stored GPS position with new coordinates if a fix is achieved, updating the coordinates the first button will display.

The overall design was meannt to minimize power consumption where possible. The form factor permitted at most a 400 mAh battery. The GPS should be able to run for around 8 hours, but in practice, battery life is much shorter. An external power supply is recommended to supplement the battery, and the GPS can operate normally while being charged via the USB-C port.
