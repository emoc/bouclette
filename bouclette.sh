#!/bin/bash

# Script pour lancer une bouclette
# le port OSC est utilisé par processing pour envoyer les messages
# le port TCP est utilisé par chuck pour compenser un bug de chuck
#   cf. https://lists.cs.princeton.edu/pipermail/chuck-users/2010-January/005226.html
#   cf. https://electro-music.com/forum/topic-39611.html
# à démarrer : sh bouclette.sh nom_du_fichier.wav port_osc port_tcp

echo "fichier à traiter => $1"
echo "port OSC => $2"

# chercher la durée du son en secondes
duree=$(soxi -D $1)
echo "duree du fichier : ${duree}"

# créer la waveform

audiowaveform -i $1 -s 0 -e ${duree} --background-color 000000 --waveform-color dddddd --no-axis-labels -w 800 -h 100 -o $1.png

# démarrer chuck avec le fichier à traiter

echo "chuck + bouclette.ck:$1:$2 &"
chuck + bouclette.ck:$1:$2 &

# démarrer processing avec le fichier à traiter et le port OSC

/home/emoc/processing-3.5.4/processing-java --sketch=/home/emoc/___GITHUB/emoc/bouclette --run $1 ${duree} $2 &




