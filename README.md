# GenOS

GenOS ist ein experimentelles 64-Bit-Betriebssystem für x86-64, das vollständig von Grund auf entsteht — ohne GRUB, ohne fremde Bibliotheken, ohne Standardbibliothek.

Der eigene Bootloader startet im BIOS-Realmodus aus dem Master Boot Record, lädt den Kernel per LBA von der Festplatte, schaltet die A20-Leitung frei, ermittelt die Speicherkarte über BIOS-Funktion E820 und führt den Prozessor über den Protected Mode bis in den Long Mode.
