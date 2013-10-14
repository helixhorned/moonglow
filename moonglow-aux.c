#include <GL/freeglut.h>

void *moonglow_get_font(int id)
{
    /* Currently: only roman and monospaced roman. */
    return id ? GLUT_STROKE_MONO_ROMAN : GLUT_STROKE_ROMAN;
}
