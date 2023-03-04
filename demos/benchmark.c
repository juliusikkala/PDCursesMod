#if defined (PDC_WIDE)
   #include <curses.h>
   #define HAVE_WIDE
#elif defined (HAVE_NCURSESW)
   #include <ncursesw/curses.h>
   #define HAVE_WIDE
#else
   #include <curses.h>
#endif
#include <math.h>
#include <stdlib.h>

#ifdef __unix__
#include<sys/time.h>
unsigned long long get_ticks()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return ((unsigned long long)tv.tv_sec)*1000000+tv.tv_usec;
}
#else
unsigned long long get_ticks()
{
    // TODO
    return 0;
}
#endif

int main(int argc, char **argv)
{
    int i = 0;
    unsigned long long delta = 0;
    unsigned long long start = 0;
    int n_colors = 0;
    int row, col;
    unsigned long long steps = 0;
#ifdef XCURSES
    Xinitscr(argc, argv);
#else
    initscr();
#endif
    start_color();
    cbreak();
    noecho();
    curs_set(0);
    leaveok(curscr, TRUE);
#ifdef __PDCURSES__
    PDC_set_title("PDCurses draw performance benchmark");
#endif

    n_colors = (COLOR_PAIRS < COLORS ? COLOR_PAIRS : COLORS);
    if(n_colors > 16384) n_colors = 16384;
    n_colors -= 16;

    if(can_change_color())
    {
        for(i = 0; i < n_colors; ++i)
        {
            init_color(
                i+16,
                sin(3*i/(float)(n_colors)*3.141592)*500.0+500.0,
                sin(5*i/(float)(n_colors)*3.141592)*500.0+500.0,
                sin(7*i/(float)(n_colors)*3.141592)*500.0+500.0
            );
            init_pair(i+16, COLOR_BLACK, i+16);
        }
    }

    timeout(0);
    delta = 0;
    start = get_ticks();
    for(;;)
    {
        unsigned long long end;
        chtype ch;
        for(row = 0; row < LINES; ++row)
        for(col = 0; col < COLS; ++col)
        {
            int x = abs(col-COLS/2);
            int y = 2*abs(row-LINES/2);
            int j = 16+(((x > y ? x : y) + steps) % n_colors);
            attrset(COLOR_PAIR(j));
            mvaddch(row, col, 'a'+((row+col+steps)%26));
        }
        mvprintw(LINES/2, COLS/2-20, "Press esc to quit. Update speed: %f", 1000000.0f/delta);

        ch = getch();
        if(ch == 27)
            break;

        end = get_ticks();
        delta = end - start;
        start = end;
        steps++;
    }
    endwin();
    return 0;
}
