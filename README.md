# Number Guessing Game

## Description

I created a number guessing game in x86 Assembly as part of a university assignment. I anticipated that by recreating a simple game in Assembly, I could make the learning process more stimulating and engaging, and indeed I found myself continuously coming up with more ideas and features to implement. It was a very enjoyable experience, and as a result of it, I've become more confident in my understanding of the language and am looking forward to experimenting further.

## How does it work?

I structured my game into 3 game modes that the player can choose from: Level 1 requires the player to guess a _randomly generated_ number ranging from 0-64, with the other two modes ranging from 0-128 and 0-255, respectively. However, the program does not truly _generate_ a random number. Instead, I used the
`int 1Ah` interrupt call to query the system clock for the number of timer ticks since midnight. The _randomness_ is derived from the unpredictable timing of when the interrupt is called, and not true entropy.

The result of the interrupt call is stored in the `CX:DX` register pair, which means the maximum possible value would be too large for the game to be enjoyable. This is where the division into three levels becomes essential from a programming perspective:

If the player selects level 1, the value 65 is loaded into the `CX` register. The value of `DX` obtained from the interrupt is transferred to the `AX` register, which is then divided by the value in `CX`. The remainder (guaranteed to fall within the desired range and always be less than or equal to 255) can be accessed via the `DL` register. This approach is used for the other two levels as well.

Once the program has generated a random number, the player can start guessing it. What happens next is pretty straightforward. If the number entered by the player is larger than the one that's been generated, the program will display a message that says "Lower! _(Mai mic!)_". If the player's guess is smaller, the program will respond with "Higher! _(Mai mare!)_". The player has a total of 10 attempts to guess the correct number. If they succeed within the given tries, their streak counter, which tracks consecutive wins, increases. If they fail, the streak counter is reset to zero, and the player is given the option to either restart the game or quit.

## Requirements
I wrote and executed the code in VS Code using the NASM/TASM extension found [here](https://marketplace.visualstudio.com/items?itemName=xsro.masm-tasm). You can use any x86-based system or emulator, along with the NASM/TASM assembler to compile the code.

## How to play

1. Run the program.
2. Press Enter to start the game.
3. Choose a difficulty level by pressing 1, 2, or 3.
4. Guess the number within 10 attempts.
5. If you guess correctly, you'll see a winning message; otherwise, you'll be prompted to try again.
6. Once the game ends, you can choose to play again or quit.

## Features

- Three difficulty levels.
- Random number generation based on system clock ticks.
- A simple & engaging UI.
- Keeps track of the number of attempts remaining.
- Displays a streak counter for consecutive wins.

## To-Do List

- Play a sound upon win or loss.
- Track win rate and other statistics.
- Add an option to save the score.

## Resources

[Introducere în limbajul de asamblare](https://zota.ase.ro/bti/Introducere_ASM.pdf)\
[8086 bios and dos interrupts](https://yassinebridi.github.io/asm-docs/8086_bios_and_dos_interrupts.html)\
[ChatGPT](https://chatgpt.com/)\
[Stack Overflow](https://stackoverflow.com/)

