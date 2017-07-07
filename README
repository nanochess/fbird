F-Bird, a text bootsector game.
by Oscar Toledo G. Jun/05/2017

http://nanochess.org
https://github.com/nanochess

Run it as a COM file or write it in the bootsector of a floppy disk.

Press any key to start, gravity makes you to fall, press any key to fly!

This game is written using pure 8088 instructions, so it should work
over an original IBM PC with CGA card. No Hercules support (though it
would be a matter of changing the video segment to B000)

Here is a Youtube video of it running over emulation:

    https://www.youtube.com/watch?v=p31XFFAeze4

If you want to assemble it, you must download the Netwide Assembler
(nasm) from www.nasm.us

Use this command line:

  nasm -f bin fbird.asm -o fbird.com

Tested with VirtualBox for Mac OS X running Windows XP running this
game, it also works with DosBox and probably with qemu:

  qemu-system-x86_64 -fda fbird.com

Note that VirtualBox doesn't emulate the PC speaker, so the "flap"
sound doesn't sound at all.

Enjoy it!

