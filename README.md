> Created on 19 Jul 2023

# Badminton Bot
*Sends a message on Telegram with the available badminton courts of each given venue*

## Features

- Able to choose between groups of community centres (CCs) to check
- Able to provide up to 10 CCs per group (the API, OnePA, is limited to 10 requests per minute) by changing the code (see below for a list of preset CCs)
- Able to select a date of up to 1 month from the current date, with the month automatically inferred from the date (however, the CCs only have data of 2-3 weeks in advance, and there is no error checking for invalid dates)
- Presents information in an easy-to-read format
  - Sections different CCs neatly and displays the number of available courts for each one
  - Lumps consecutive available slots into the same line
  - Contains a section for fully booked CCs to avoid clutter

## Preset Venues

- Central
  - Whampoa
  - Bidadari
  - Toa Payoh East
  - Toa Payoh South
  - Toa Payoh West
  - Bishan
  - Marymount
  - Braddell Heights
  - Kebun Baru
  - Teck Ghee
- East
  - Tampines Changkat
  - Tampines East
  - Tampines North
  - Bedok
  - Fengshan
  - Eunos
  - Kaki Bukit
  - Siglap
  - Changi Simei
  - Kallang
