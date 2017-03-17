/**
 KKY/Projekt 4 
 Markéta Jedličková
 **/

import processing.video.*;
import javax.sound.midi.*;

// volitelne parametry programu
int pocetKlaves = 2;   // volitelné, doporučená hodnota 2 
int pocetRad = 3;      // volitelné, doporučená hodnota 3
int sirka = 640;       // volitelné, doporučená šířka videa 640
int vyska = 480;       // volitelné, doporučená výška videa 480
int maxProstredi = 55; // volitelné, max ruseni prostredi ve kterem bude hrat nota je dobre volit mezi (35 - 60)
int minProstredi = 45; // volitelné, min ruseni prostredi od ktere hodnoty ruseni zacne nota hrat je dobre volit mezi (15 - 50)

// dopočtení dalších proměnných
int sirkaKlavesy= sirka/pocetKlaves; 
int vyskaKlavesy= vyska/pocetRad;
int maxRuseni=sirkaKlavesy*vyskaKlavesy*maxProstredi; // jeste prijatelne zmeny v prostredi
int minRuseni=sirkaKlavesy*vyskaKlavesy*minProstredi; // minimalni povolene ruseni

// pomocné tabulky na uložení potřebných hodnot
int[][] poleNot = new int[2][pocetKlaves*pocetRad]; // pole not, obsahuje hodnoty not a uchovává informaci o tom zda je nota zapnutá či ne
int[][] poleZmen = new int[2][pocetKlaves*pocetRad]; // uchovává informace o výšši změn v jednotlivých oblastech (na klávesách)

// deklarace zbylých proměnných
int pocetPixelu;
Capture video;
int[] predchoziSnimek;
Synthesizer synth = null;
int posun = 0;
int indexNoty = 0;
int k=0;

void setup() {
  size(sirka, vyska);  // nastaveni velikosti okna na 640x480
  smooth();            // aliasing
  strokeWeight(2);     // sirka car
  stroke(150);         // barva car

  video = new Capture(this, width, height, 24);  // nastaveni videa 24 snimku za sekundu
  pocetPixelu = video.width * video.height;      // pocet pixelu   
  predchoziSnimek = new int[pocetPixelu];        // predchozi snimek ulozime jako tabulku pixelu

  for (int i=0; i< pocetKlaves*pocetRad ; i++) { // naplneni pole not
    poleNot[1][i] = 0;                           // 0 predstavuje false, neboli nota je vypnuta
    poleNot[0][i]=60+2*i;
  }

  try { 
    synth = MidiSystem.getSynthesizer();
    synth.open();
  } 
  catch (MidiUnavailableException e) {
    e.printStackTrace();
    System.exit(1);
  }

  loadPixels();             // nacteme pixely
}

void draw() {
  if (video.available()) {  // pokud je video dostupné
    video.read();           // přečti video 
    video.loadPixels();     // načti pixely

    MidiChannel[] channels = synth.getChannels();
    MidiChannel channel = channels[0];

    // vykreslení rozdělení kláves
    for (int i=sirka/pocetKlaves; i<sirka ;i=i+(sirka/pocetKlaves)) {
      line(i, 0, i, vyska);
    }
    for(int i=vyska/pocetRad; i<vyska ;i=i+(vyska/pocetRad)) {
      line(0, i, sirka, i);
    }

    // vynulování změn pro další obraz
    int celkemZmen = 0; 

    for(int i=0; i< pocetKlaves*pocetRad ;i++) {
      poleZmen[0][i] = 0;
      poleZmen[1][i] = 0;
    }
    
    int mira = sirkaKlavesy;  // na začátku je míra rovna šířce klávesy
    k=0;                      // vynulování indexu k
    posun=0;                  // vynulovaní posunu
    for (int s = 0; s < pocetPixelu; s++) {
      color soucBarva = video.pixels[s];
      color predBarva = predchoziSnimek[s];
      int soucR = (soucBarva >> 16) & 0xFF;
      int soucG = (soucBarva >> 8) & 0xFF;
      int soucB = soucBarva & 0xFF;

      int predR = (predBarva >> 16) & 0xFF;
      int predG = (predBarva >> 8) & 0xFF;
      int predB = predBarva & 0xFF;

      int rozdR = abs(soucR - predR);
      int rozdG = abs(soucG - predG);
      int rozdB = abs(soucB - predB);

      if ( s < mira ) {                                                     // s je číslo pixelu na kterém se zrovna nacházíme, míra je vymezení klávesy
        poleZmen[0][k] += rozdR + rozdG + rozdB;
        poleZmen[1][k] += 1;

        celkemZmen += rozdR + rozdG + rozdB;
        pixels[s] = color(rozdR, rozdG, rozdB);
        predchoziSnimek[s] = soucBarva;
      }
      else {
        if(s%sirka==0) {                                                    // pokud jsme dorazili na konec řádky (obrazu) 
          if(poleZmen[1][posun+pocetKlaves-1]==sirkaKlavesy*vyskaKlavesy) { // pokud jsme už spočítali změny celé klávesy
            k=posun+pocetKlaves;                                            // posun na další řádku        
            posun=posun+pocetKlaves;                                        
          }
          else {
            k=posun;                                                        // zůstaň ve stejné oblasti
          }
        }   
        else {
          k++;                                                              // posun na další klávesu
        }

        mira = mira+sirkaKlavesy;                                           // posunutí míry
        s--;                                                                
      }
    }

    if (celkemZmen > 0) {   
      for(int i=0; i<pocetKlaves*pocetRad; i++) {
        if (poleZmen[0][i]>minRuseni && poleZmen[0][i]<maxRuseni  ) {       // pokud jsme v daných mezích zapni notu, jinak vypni notu
          zapniNotu(poleNot[0][i], channel); 
        }
        else {
          vypniNotu(poleNot[0][i], channel);
        }
      }
      updatePixels();                                                       // aktualizuj pixely
    }
  }
}

