require("ffi").cdef[[
typedef unsigned int GLenum;
typedef unsigned char GLboolean;
typedef unsigned int GLbitfield;
typedef void GLvoid;
typedef signed char GLbyte;
typedef short GLshort;
typedef int GLint;
typedef unsigned char GLubyte;
typedef unsigned short GLushort;
typedef unsigned int GLuint;
typedef int GLsizei;
typedef float GLfloat;
typedef float GLclampf;
typedef double GLdouble;
typedef double GLclampd;
typedef char GLchar;
typedef int GLintptr;
typedef int GLsizeiptr;
void glutInit(int *, char **);
void glutInitWindowPosition(int, int);
void glutInitWindowSize(int, int);
void glutInitDisplayMode(unsigned int);
void glutInitDisplayString(const char *);
void glutMainLoop();
int glutCreateWindow(const char *);
int glutCreateSubWindow(int, int, int, int, int);
void glutDestroyWindow(int);
void glutSetWindow(int);
int glutGetWindow();
void glutSetWindowTitle(const char *);
void glutSetIconTitle(const char *);
void glutReshapeWindow(int, int);
void glutPositionWindow(int, int);
void glutShowWindow();
void glutHideWindow();
void glutIconifyWindow();
void glutPushWindow();
void glutPopWindow();
void glutFullScreen();
void glutPostWindowRedisplay(int);
void glutPostRedisplay();
void glutSwapBuffers();
void glutWarpPointer(int, int);
void glutSetCursor(int);
void glutEstablishOverlay();
void glutRemoveOverlay();
void glutUseLayer(GLenum);
void glutPostOverlayRedisplay();
void glutPostWindowOverlayRedisplay(int);
void glutShowOverlay();
void glutHideOverlay();
int glutCreateMenu(void (*)(int));
void glutDestroyMenu(int);
int glutGetMenu();
void glutSetMenu(int);
void glutAddMenuEntry(const char *, int);
void glutAddSubMenu(const char *, int);
void glutChangeToMenuEntry(int, const char *, int);
void glutChangeToSubMenu(int, const char *, int);
void glutRemoveMenuItem(int);
void glutAttachMenu(int);
void glutDetachMenu(int);
void glutTimerFunc(unsigned int, void (*)(int), int);
void glutIdleFunc(void (*)(void));
void glutKeyboardFunc(void (*)(unsigned char, int, int));
void glutSpecialFunc(void (*)(int, int, int));
void glutReshapeFunc(void (*)(int, int));
void glutVisibilityFunc(void (*)(int));
void glutDisplayFunc(void (*)(void));
void glutMouseFunc(void (*)(int, int, int, int));
void glutMotionFunc(void (*)(int, int));
void glutPassiveMotionFunc(void (*)(int, int));
void glutEntryFunc(void (*)(int));
void glutKeyboardUpFunc(void (*)(unsigned char, int, int));
void glutSpecialUpFunc(void (*)(int, int, int));
void glutJoystickFunc(void (*)(unsigned int, int, int, int), int);
void glutMenuStateFunc(void (*)(int));
void glutMenuStatusFunc(void (*)(int, int, int));
void glutOverlayDisplayFunc(void (*)(void));
void glutWindowStatusFunc(void (*)(int));
void glutSpaceballMotionFunc(void (*)(int, int, int));
void glutSpaceballRotateFunc(void (*)(int, int, int));
void glutSpaceballButtonFunc(void (*)(int, int));
void glutButtonBoxFunc(void (*)(int, int));
void glutDialsFunc(void (*)(int, int));
void glutTabletMotionFunc(void (*)(int, int));
void glutTabletButtonFunc(void (*)(int, int, int, int));
int glutGet(GLenum);
int glutDeviceGet(GLenum);
int glutGetModifiers();
int glutLayerGet(GLenum);
void glutBitmapCharacter(void *, int);
int glutBitmapWidth(void *, int);
void glutStrokeCharacter(void *, int);
int glutStrokeWidth(void *, int);
int glutBitmapLength(void *, const unsigned char *);
int glutStrokeLength(void *, const unsigned char *);
void glutWireCube(double);
void glutSolidCube(double);
void glutWireSphere(double, GLint, GLint);
void glutSolidSphere(double, GLint, GLint);
void glutWireCone(double, double, GLint, GLint);
void glutSolidCone(double, double, GLint, GLint);
void glutWireTorus(double, double, GLint, GLint);
void glutSolidTorus(double, double, GLint, GLint);
void glutWireDodecahedron();
void glutSolidDodecahedron();
void glutWireOctahedron();
void glutSolidOctahedron();
void glutWireTetrahedron();
void glutSolidTetrahedron();
void glutWireIcosahedron();
void glutSolidIcosahedron();
void glutWireTeapot(double);
void glutSolidTeapot(double);
void glutGameModeString(const char *);
int glutEnterGameMode();
void glutLeaveGameMode();
int glutGameModeGet(GLenum);
int glutVideoResizeGet(GLenum);
void glutSetupVideoResizing();
void glutStopVideoResizing();
void glutVideoResize(int, int, int, int);
void glutVideoPan(int, int, int, int);
void glutSetColor(int, GLfloat, GLfloat, GLfloat);
GLfloat glutGetColor(int, int);
void glutCopyColormap(int);
void glutIgnoreKeyRepeat(int);
void glutSetKeyRepeat(int);
void glutForceJoystickFunc();
int glutExtensionSupported(const char *);
void glutReportErrors();
void glutMainLoopEvent();
void glutLeaveMainLoop();
void glutExit();
void glutFullScreenToggle();
void glutLeaveFullScreen();
void glutSetMenuFont(int, void *);
void glutMouseWheelFunc(void (*)(int, int, int, int));
void glutPositionFunc(void (*)(int, int));
void glutCloseFunc(void (*)(void));
void glutWMCloseFunc(void (*)(void));
void glutMenuDestroyFunc(void (*)(void));
void glutSetOption(GLenum, int);
int * glutGetModeValues(GLenum, int *);
void * glutGetWindowData();
void glutSetWindowData(void *);
void * glutGetMenuData();
void glutSetMenuData(void *);
int glutBitmapHeight(void *);
GLfloat glutStrokeHeight(void *);
void glutBitmapString(void *, const unsigned char *);
void glutStrokeString(void *, const unsigned char *);
void glutWireRhombicDodecahedron();
void glutSolidRhombicDodecahedron();
void glutWireSierpinskiSponge(int, double *, double);
void glutSolidSierpinskiSponge(int, double *, double);
void glutWireCylinder(double, double, GLint, GLint);
void glutSolidCylinder(double, double, GLint, GLint);
void glutWireTeacup(double);
void glutSolidTeacup(double);
void glutWireTeaspoon(double);
void glutSolidTeaspoon(double);
void glutMultiEntryFunc(void (*)(int, int));
void glutMultiButtonFunc(void (*)(int, int, int, int, int));
void glutMultiMotionFunc(void (*)(int, int, int));
void glutMultiPassiveFunc(void (*)(int, int, int));
int glutJoystickGetNumAxes(int);
int glutJoystickGetNumButtons(int);
int glutJoystickNotWorking(int);
float glutJoystickGetDeadBand(int, int);
void glutJoystickSetDeadBand(int, int, float);
float glutJoystickGetSaturation(int, int);
void glutJoystickSetSaturation(int, int, float);
void glutJoystickSetMinRange(int, float *);
void glutJoystickSetMaxRange(int, float *);
void glutJoystickSetCenter(int, float *);
void glutJoystickGetMinRange(int, float *);
void glutJoystickGetMaxRange(int, float *);
void glutJoystickGetCenter(int, float *);
void glutInitContextVersion(int, int);
void glutInitContextFlags(int);
void glutInitContextProfile(int);
void glutInitErrorFunc(void (*)(const char *, int));
void glutInitWarningFunc(void (*)(const char *, int));
void glutSetVertexAttribCoord3(GLint);
void glutSetVertexAttribNormal(GLint);
void glutSetVertexAttribTexCoord2(GLint);
void glutInitContextFunc(void (*)());
void glutAppStatusFunc(void (*)(int));
void glClearIndex(GLfloat);
void glClearColor(GLclampf, GLclampf, GLclampf, GLclampf);
void glClear(GLbitfield);
void glIndexMask(GLuint);
void glColorMask(GLboolean, GLboolean, GLboolean, GLboolean);
void glAlphaFunc(GLenum, GLclampf);
void glBlendFunc(GLenum, GLenum);
void glLogicOp(GLenum);
void glCullFace(GLenum);
void glFrontFace(GLenum);
void glPointSize(GLfloat);
void glLineWidth(GLfloat);
void glLineStipple(GLint, GLushort);
void glPolygonMode(GLenum, GLenum);
void glPolygonOffset(GLfloat, GLfloat);
void glPolygonStipple(const GLubyte *);
void glGetPolygonStipple(GLubyte *);
void glEdgeFlag(GLboolean);
void glEdgeFlagv(const GLboolean *);
void glScissor(GLint, GLint, GLsizei, GLsizei);
void glClipPlane(GLenum, const GLdouble *);
void glGetClipPlane(GLenum, GLdouble *);
void glDrawBuffer(GLenum);
void glReadBuffer(GLenum);
void glEnable(GLenum);
void glDisable(GLenum);
GLboolean glIsEnabled(GLenum);
void glEnableClientState(GLenum);
void glDisableClientState(GLenum);
void glGetBooleanv(GLenum, GLboolean *);
void glGetDoublev(GLenum, GLdouble *);
void glGetFloatv(GLenum, GLfloat *);
void glGetIntegerv(GLenum, GLint *);
void glPushAttrib(GLbitfield);
void glPopAttrib();
void glPushClientAttrib(GLbitfield);
void glPopClientAttrib();
GLint glRenderMode(GLenum);
GLenum glGetError();
const GLubyte * glGetString(GLenum);
void glFinish();
void glFlush();
void glHint(GLenum, GLenum);
void glClearDepth(GLclampd);
void glDepthFunc(GLenum);
void glDepthMask(GLboolean);
void glDepthRange(GLclampd, GLclampd);
void glClearAccum(GLfloat, GLfloat, GLfloat, GLfloat);
void glAccum(GLenum, GLfloat);
void glMatrixMode(GLenum);
void glOrtho(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble);
void glFrustum(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble);
void glViewport(GLint, GLint, GLsizei, GLsizei);
void glPushMatrix();
void glPopMatrix();
void glLoadIdentity();
void glLoadMatrixd(const GLdouble *);
void glLoadMatrixf(const GLfloat *);
void glMultMatrixd(const GLdouble *);
void glMultMatrixf(const GLfloat *);
void glRotated(GLdouble, GLdouble, GLdouble, GLdouble);
void glRotatef(GLfloat, GLfloat, GLfloat, GLfloat);
void glScaled(GLdouble, GLdouble, GLdouble);
void glScalef(GLfloat, GLfloat, GLfloat);
void glTranslated(GLdouble, GLdouble, GLdouble);
void glTranslatef(GLfloat, GLfloat, GLfloat);
GLboolean glIsList(GLuint);
void glDeleteLists(GLuint, GLsizei);
GLuint glGenLists(GLsizei);
void glNewList(GLuint, GLenum);
void glEndList();
void glCallList(GLuint);
void glCallLists(GLsizei, GLenum, const GLvoid *);
void glListBase(GLuint);
void glBegin(GLenum);
void glEnd();
void glVertex2d(GLdouble, GLdouble);
void glVertex2f(GLfloat, GLfloat);
void glVertex2i(GLint, GLint);
void glVertex2s(GLshort, GLshort);
void glVertex3d(GLdouble, GLdouble, GLdouble);
void glVertex3f(GLfloat, GLfloat, GLfloat);
void glVertex3i(GLint, GLint, GLint);
void glVertex3s(GLshort, GLshort, GLshort);
void glVertex4d(GLdouble, GLdouble, GLdouble, GLdouble);
void glVertex4f(GLfloat, GLfloat, GLfloat, GLfloat);
void glVertex4i(GLint, GLint, GLint, GLint);
void glVertex4s(GLshort, GLshort, GLshort, GLshort);
void glVertex2dv(const GLdouble *);
void glVertex2fv(const GLfloat *);
void glVertex2iv(const GLint *);
void glVertex2sv(const GLshort *);
void glVertex3dv(const GLdouble *);
void glVertex3fv(const GLfloat *);
void glVertex3iv(const GLint *);
void glVertex3sv(const GLshort *);
void glVertex4dv(const GLdouble *);
void glVertex4fv(const GLfloat *);
void glVertex4iv(const GLint *);
void glVertex4sv(const GLshort *);
void glNormal3b(GLbyte, GLbyte, GLbyte);
void glNormal3d(GLdouble, GLdouble, GLdouble);
void glNormal3f(GLfloat, GLfloat, GLfloat);
void glNormal3i(GLint, GLint, GLint);
void glNormal3s(GLshort, GLshort, GLshort);
void glNormal3bv(const GLbyte *);
void glNormal3dv(const GLdouble *);
void glNormal3fv(const GLfloat *);
void glNormal3iv(const GLint *);
void glNormal3sv(const GLshort *);
void glIndexd(GLdouble);
void glIndexf(GLfloat);
void glIndexi(GLint);
void glIndexs(GLshort);
void glIndexub(GLubyte);
void glIndexdv(const GLdouble *);
void glIndexfv(const GLfloat *);
void glIndexiv(const GLint *);
void glIndexsv(const GLshort *);
void glIndexubv(const GLubyte *);
void glColor3b(GLbyte, GLbyte, GLbyte);
void glColor3d(GLdouble, GLdouble, GLdouble);
void glColor3f(GLfloat, GLfloat, GLfloat);
void glColor3i(GLint, GLint, GLint);
void glColor3s(GLshort, GLshort, GLshort);
void glColor3ub(GLubyte, GLubyte, GLubyte);
void glColor3ui(GLuint, GLuint, GLuint);
void glColor3us(GLushort, GLushort, GLushort);
void glColor4b(GLbyte, GLbyte, GLbyte, GLbyte);
void glColor4d(GLdouble, GLdouble, GLdouble, GLdouble);
void glColor4f(GLfloat, GLfloat, GLfloat, GLfloat);
void glColor4i(GLint, GLint, GLint, GLint);
void glColor4s(GLshort, GLshort, GLshort, GLshort);
void glColor4ub(GLubyte, GLubyte, GLubyte, GLubyte);
void glColor4ui(GLuint, GLuint, GLuint, GLuint);
void glColor4us(GLushort, GLushort, GLushort, GLushort);
void glColor3bv(const GLbyte *);
void glColor3dv(const GLdouble *);
void glColor3fv(const GLfloat *);
void glColor3iv(const GLint *);
void glColor3sv(const GLshort *);
void glColor3ubv(const GLubyte *);
void glColor3uiv(const GLuint *);
void glColor3usv(const GLushort *);
void glColor4bv(const GLbyte *);
void glColor4dv(const GLdouble *);
void glColor4fv(const GLfloat *);
void glColor4iv(const GLint *);
void glColor4sv(const GLshort *);
void glColor4ubv(const GLubyte *);
void glColor4uiv(const GLuint *);
void glColor4usv(const GLushort *);
void glTexCoord1d(GLdouble);
void glTexCoord1f(GLfloat);
void glTexCoord1i(GLint);
void glTexCoord1s(GLshort);
void glTexCoord2d(GLdouble, GLdouble);
void glTexCoord2f(GLfloat, GLfloat);
void glTexCoord2i(GLint, GLint);
void glTexCoord2s(GLshort, GLshort);
void glTexCoord3d(GLdouble, GLdouble, GLdouble);
void glTexCoord3f(GLfloat, GLfloat, GLfloat);
void glTexCoord3i(GLint, GLint, GLint);
void glTexCoord3s(GLshort, GLshort, GLshort);
void glTexCoord4d(GLdouble, GLdouble, GLdouble, GLdouble);
void glTexCoord4f(GLfloat, GLfloat, GLfloat, GLfloat);
void glTexCoord4i(GLint, GLint, GLint, GLint);
void glTexCoord4s(GLshort, GLshort, GLshort, GLshort);
void glTexCoord1dv(const GLdouble *);
void glTexCoord1fv(const GLfloat *);
void glTexCoord1iv(const GLint *);
void glTexCoord1sv(const GLshort *);
void glTexCoord2dv(const GLdouble *);
void glTexCoord2fv(const GLfloat *);
void glTexCoord2iv(const GLint *);
void glTexCoord2sv(const GLshort *);
void glTexCoord3dv(const GLdouble *);
void glTexCoord3fv(const GLfloat *);
void glTexCoord3iv(const GLint *);
void glTexCoord3sv(const GLshort *);
void glTexCoord4dv(const GLdouble *);
void glTexCoord4fv(const GLfloat *);
void glTexCoord4iv(const GLint *);
void glTexCoord4sv(const GLshort *);
void glRasterPos2d(GLdouble, GLdouble);
void glRasterPos2f(GLfloat, GLfloat);
void glRasterPos2i(GLint, GLint);
void glRasterPos2s(GLshort, GLshort);
void glRasterPos3d(GLdouble, GLdouble, GLdouble);
void glRasterPos3f(GLfloat, GLfloat, GLfloat);
void glRasterPos3i(GLint, GLint, GLint);
void glRasterPos3s(GLshort, GLshort, GLshort);
void glRasterPos4d(GLdouble, GLdouble, GLdouble, GLdouble);
void glRasterPos4f(GLfloat, GLfloat, GLfloat, GLfloat);
void glRasterPos4i(GLint, GLint, GLint, GLint);
void glRasterPos4s(GLshort, GLshort, GLshort, GLshort);
void glRasterPos2dv(const GLdouble *);
void glRasterPos2fv(const GLfloat *);
void glRasterPos2iv(const GLint *);
void glRasterPos2sv(const GLshort *);
void glRasterPos3dv(const GLdouble *);
void glRasterPos3fv(const GLfloat *);
void glRasterPos3iv(const GLint *);
void glRasterPos3sv(const GLshort *);
void glRasterPos4dv(const GLdouble *);
void glRasterPos4fv(const GLfloat *);
void glRasterPos4iv(const GLint *);
void glRasterPos4sv(const GLshort *);
void glRectd(GLdouble, GLdouble, GLdouble, GLdouble);
void glRectf(GLfloat, GLfloat, GLfloat, GLfloat);
void glRecti(GLint, GLint, GLint, GLint);
void glRects(GLshort, GLshort, GLshort, GLshort);
void glRectdv(const GLdouble *, const GLdouble *);
void glRectfv(const GLfloat *, const GLfloat *);
void glRectiv(const GLint *, const GLint *);
void glRectsv(const GLshort *, const GLshort *);
void glVertexPointer(GLint, GLenum, GLsizei, const GLvoid *);
void glNormalPointer(GLenum, GLsizei, const GLvoid *);
void glColorPointer(GLint, GLenum, GLsizei, const GLvoid *);
void glIndexPointer(GLenum, GLsizei, const GLvoid *);
void glTexCoordPointer(GLint, GLenum, GLsizei, const GLvoid *);
void glEdgeFlagPointer(GLsizei, const GLvoid *);
void glGetPointerv(GLenum, GLvoid **);
void glArrayElement(GLint);
void glDrawArrays(GLenum, GLint, GLsizei);
void glDrawElements(GLenum, GLsizei, GLenum, const GLvoid *);
void glInterleavedArrays(GLenum, GLsizei, const GLvoid *);
void glShadeModel(GLenum);
void glLightf(GLenum, GLenum, GLfloat);
void glLighti(GLenum, GLenum, GLint);
void glLightfv(GLenum, GLenum, const GLfloat *);
void glLightiv(GLenum, GLenum, const GLint *);
void glGetLightfv(GLenum, GLenum, GLfloat *);
void glGetLightiv(GLenum, GLenum, GLint *);
void glLightModelf(GLenum, GLfloat);
void glLightModeli(GLenum, GLint);
void glLightModelfv(GLenum, const GLfloat *);
void glLightModeliv(GLenum, const GLint *);
void glMaterialf(GLenum, GLenum, GLfloat);
void glMateriali(GLenum, GLenum, GLint);
void glMaterialfv(GLenum, GLenum, const GLfloat *);
void glMaterialiv(GLenum, GLenum, const GLint *);
void glGetMaterialfv(GLenum, GLenum, GLfloat *);
void glGetMaterialiv(GLenum, GLenum, GLint *);
void glColorMaterial(GLenum, GLenum);
void glPixelZoom(GLfloat, GLfloat);
void glPixelStoref(GLenum, GLfloat);
void glPixelStorei(GLenum, GLint);
void glPixelTransferf(GLenum, GLfloat);
void glPixelTransferi(GLenum, GLint);
void glPixelMapfv(GLenum, GLsizei, const GLfloat *);
void glPixelMapuiv(GLenum, GLsizei, const GLuint *);
void glPixelMapusv(GLenum, GLsizei, const GLushort *);
void glGetPixelMapfv(GLenum, GLfloat *);
void glGetPixelMapuiv(GLenum, GLuint *);
void glGetPixelMapusv(GLenum, GLushort *);
void glBitmap(GLsizei, GLsizei, GLfloat, GLfloat, GLfloat, GLfloat, const GLubyte *);
void glReadPixels(GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, GLvoid *);
void glDrawPixels(GLsizei, GLsizei, GLenum, GLenum, const GLvoid *);
void glCopyPixels(GLint, GLint, GLsizei, GLsizei, GLenum);
void glStencilFunc(GLenum, GLint, GLuint);
void glStencilMask(GLuint);
void glStencilOp(GLenum, GLenum, GLenum);
void glClearStencil(GLint);
void glTexGend(GLenum, GLenum, GLdouble);
void glTexGenf(GLenum, GLenum, GLfloat);
void glTexGeni(GLenum, GLenum, GLint);
void glTexGendv(GLenum, GLenum, const GLdouble *);
void glTexGenfv(GLenum, GLenum, const GLfloat *);
void glTexGeniv(GLenum, GLenum, const GLint *);
void glGetTexGendv(GLenum, GLenum, GLdouble *);
void glGetTexGenfv(GLenum, GLenum, GLfloat *);
void glGetTexGeniv(GLenum, GLenum, GLint *);
void glTexEnvf(GLenum, GLenum, GLfloat);
void glTexEnvi(GLenum, GLenum, GLint);
void glTexEnvfv(GLenum, GLenum, const GLfloat *);
void glTexEnviv(GLenum, GLenum, const GLint *);
void glGetTexEnvfv(GLenum, GLenum, GLfloat *);
void glGetTexEnviv(GLenum, GLenum, GLint *);
void glTexParameterf(GLenum, GLenum, GLfloat);
void glTexParameteri(GLenum, GLenum, GLint);
void glTexParameterfv(GLenum, GLenum, const GLfloat *);
void glTexParameteriv(GLenum, GLenum, const GLint *);
void glGetTexParameterfv(GLenum, GLenum, GLfloat *);
void glGetTexParameteriv(GLenum, GLenum, GLint *);
void glGetTexLevelParameterfv(GLenum, GLint, GLenum, GLfloat *);
void glGetTexLevelParameteriv(GLenum, GLint, GLenum, GLint *);
void glTexImage1D(GLenum, GLint, GLint, GLsizei, GLint, GLenum, GLenum, const GLvoid *);
void glTexImage2D(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid *);
void glGetTexImage(GLenum, GLint, GLenum, GLenum, GLvoid *);
void glGenTextures(GLsizei, GLuint *);
void glDeleteTextures(GLsizei, const GLuint *);
void glBindTexture(GLenum, GLuint);
void glPrioritizeTextures(GLsizei, const GLuint *, const GLclampf *);
GLboolean glAreTexturesResident(GLsizei, const GLuint *, GLboolean *);
GLboolean glIsTexture(GLuint);
void glTexSubImage1D(GLenum, GLint, GLint, GLsizei, GLenum, GLenum, const GLvoid *);
void glTexSubImage2D(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, const GLvoid *);
void glCopyTexImage1D(GLenum, GLint, GLenum, GLint, GLint, GLsizei, GLint);
void glCopyTexImage2D(GLenum, GLint, GLenum, GLint, GLint, GLsizei, GLsizei, GLint);
void glCopyTexSubImage1D(GLenum, GLint, GLint, GLint, GLint, GLsizei);
void glCopyTexSubImage2D(GLenum, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei);
void glMap1d(GLenum, GLdouble, GLdouble, GLint, GLint, const GLdouble *);
void glMap1f(GLenum, GLfloat, GLfloat, GLint, GLint, const GLfloat *);
void glMap2d(GLenum, GLdouble, GLdouble, GLint, GLint, GLdouble, GLdouble, GLint, GLint, const GLdouble *);
void glMap2f(GLenum, GLfloat, GLfloat, GLint, GLint, GLfloat, GLfloat, GLint, GLint, const GLfloat *);
void glGetMapdv(GLenum, GLenum, GLdouble *);
void glGetMapfv(GLenum, GLenum, GLfloat *);
void glGetMapiv(GLenum, GLenum, GLint *);
void glEvalCoord1d(GLdouble);
void glEvalCoord1f(GLfloat);
void glEvalCoord1dv(const GLdouble *);
void glEvalCoord1fv(const GLfloat *);
void glEvalCoord2d(GLdouble, GLdouble);
void glEvalCoord2f(GLfloat, GLfloat);
void glEvalCoord2dv(const GLdouble *);
void glEvalCoord2fv(const GLfloat *);
void glMapGrid1d(GLint, GLdouble, GLdouble);
void glMapGrid1f(GLint, GLfloat, GLfloat);
void glMapGrid2d(GLint, GLdouble, GLdouble, GLint, GLdouble, GLdouble);
void glMapGrid2f(GLint, GLfloat, GLfloat, GLint, GLfloat, GLfloat);
void glEvalPoint1(GLint);
void glEvalPoint2(GLint, GLint);
void glEvalMesh1(GLenum, GLint, GLint);
void glEvalMesh2(GLenum, GLint, GLint, GLint, GLint);
void glFogf(GLenum, GLfloat);
void glFogi(GLenum, GLint);
void glFogfv(GLenum, const GLfloat *);
void glFogiv(GLenum, const GLint *);
void glFeedbackBuffer(GLsizei, GLenum, GLfloat *);
void glPassThrough(GLfloat);
void glSelectBuffer(GLsizei, GLuint *);
void glInitNames();
void glLoadName(GLuint);
void glPushName(GLuint);
void glPopName();
void glDrawRangeElements(GLenum, GLuint, GLuint, GLsizei, GLenum, const GLvoid *);
void glTexImage3D(GLenum, GLint, GLint, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid *);
void glTexSubImage3D(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLenum, const GLvoid *);
void glCopyTexSubImage3D(GLenum, GLint, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei);
void glColorTable(GLenum, GLenum, GLsizei, GLenum, GLenum, const GLvoid *);
void glColorSubTable(GLenum, GLsizei, GLsizei, GLenum, GLenum, const GLvoid *);
void glColorTableParameteriv(GLenum, GLenum, const GLint *);
void glColorTableParameterfv(GLenum, GLenum, const GLfloat *);
void glCopyColorSubTable(GLenum, GLsizei, GLint, GLint, GLsizei);
void glCopyColorTable(GLenum, GLenum, GLint, GLint, GLsizei);
void glGetColorTable(GLenum, GLenum, GLenum, GLvoid *);
void glGetColorTableParameterfv(GLenum, GLenum, GLfloat *);
void glGetColorTableParameteriv(GLenum, GLenum, GLint *);
void glBlendEquation(GLenum);
void glBlendColor(GLclampf, GLclampf, GLclampf, GLclampf);
void glHistogram(GLenum, GLsizei, GLenum, GLboolean);
void glResetHistogram(GLenum);
void glGetHistogram(GLenum, GLboolean, GLenum, GLenum, GLvoid *);
void glGetHistogramParameterfv(GLenum, GLenum, GLfloat *);
void glGetHistogramParameteriv(GLenum, GLenum, GLint *);
void glMinmax(GLenum, GLenum, GLboolean);
void glResetMinmax(GLenum);
void glGetMinmax(GLenum, GLboolean, GLenum, GLenum, GLvoid *);
void glGetMinmaxParameterfv(GLenum, GLenum, GLfloat *);
void glGetMinmaxParameteriv(GLenum, GLenum, GLint *);
void glConvolutionFilter1D(GLenum, GLenum, GLsizei, GLenum, GLenum, const GLvoid *);
void glConvolutionFilter2D(GLenum, GLenum, GLsizei, GLsizei, GLenum, GLenum, const GLvoid *);
void glConvolutionParameterf(GLenum, GLenum, GLfloat);
void glConvolutionParameterfv(GLenum, GLenum, const GLfloat *);
void glConvolutionParameteri(GLenum, GLenum, GLint);
void glConvolutionParameteriv(GLenum, GLenum, const GLint *);
void glCopyConvolutionFilter1D(GLenum, GLenum, GLint, GLint, GLsizei);
void glCopyConvolutionFilter2D(GLenum, GLenum, GLint, GLint, GLsizei, GLsizei);
void glGetConvolutionFilter(GLenum, GLenum, GLenum, GLvoid *);
void glGetConvolutionParameterfv(GLenum, GLenum, GLfloat *);
void glGetConvolutionParameteriv(GLenum, GLenum, GLint *);
void glSeparableFilter2D(GLenum, GLenum, GLsizei, GLsizei, GLenum, GLenum, const GLvoid *, const GLvoid *);
void glGetSeparableFilter(GLenum, GLenum, GLenum, GLvoid *, GLvoid *, GLvoid *);
void glActiveTexture(GLenum);
void glClientActiveTexture(GLenum);
void glCompressedTexImage1D(GLenum, GLint, GLenum, GLsizei, GLint, GLsizei, const GLvoid *);
void glCompressedTexImage2D(GLenum, GLint, GLenum, GLsizei, GLsizei, GLint, GLsizei, const GLvoid *);
void glCompressedTexImage3D(GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLint, GLsizei, const GLvoid *);
void glCompressedTexSubImage1D(GLenum, GLint, GLint, GLsizei, GLenum, GLsizei, const GLvoid *);
void glCompressedTexSubImage2D(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLsizei, const GLvoid *);
void glCompressedTexSubImage3D(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLsizei, const GLvoid *);
void glGetCompressedTexImage(GLenum, GLint, GLvoid *);
void glMultiTexCoord1d(GLenum, GLdouble);
void glMultiTexCoord1dv(GLenum, const GLdouble *);
void glMultiTexCoord1f(GLenum, GLfloat);
void glMultiTexCoord1fv(GLenum, const GLfloat *);
void glMultiTexCoord1i(GLenum, GLint);
void glMultiTexCoord1iv(GLenum, const GLint *);
void glMultiTexCoord1s(GLenum, GLshort);
void glMultiTexCoord1sv(GLenum, const GLshort *);
void glMultiTexCoord2d(GLenum, GLdouble, GLdouble);
void glMultiTexCoord2dv(GLenum, const GLdouble *);
void glMultiTexCoord2f(GLenum, GLfloat, GLfloat);
void glMultiTexCoord2fv(GLenum, const GLfloat *);
void glMultiTexCoord2i(GLenum, GLint, GLint);
void glMultiTexCoord2iv(GLenum, const GLint *);
void glMultiTexCoord2s(GLenum, GLshort, GLshort);
void glMultiTexCoord2sv(GLenum, const GLshort *);
void glMultiTexCoord3d(GLenum, GLdouble, GLdouble, GLdouble);
void glMultiTexCoord3dv(GLenum, const GLdouble *);
void glMultiTexCoord3f(GLenum, GLfloat, GLfloat, GLfloat);
void glMultiTexCoord3fv(GLenum, const GLfloat *);
void glMultiTexCoord3i(GLenum, GLint, GLint, GLint);
void glMultiTexCoord3iv(GLenum, const GLint *);
void glMultiTexCoord3s(GLenum, GLshort, GLshort, GLshort);
void glMultiTexCoord3sv(GLenum, const GLshort *);
void glMultiTexCoord4d(GLenum, GLdouble, GLdouble, GLdouble, GLdouble);
void glMultiTexCoord4dv(GLenum, const GLdouble *);
void glMultiTexCoord4f(GLenum, GLfloat, GLfloat, GLfloat, GLfloat);
void glMultiTexCoord4fv(GLenum, const GLfloat *);
void glMultiTexCoord4i(GLenum, GLint, GLint, GLint, GLint);
void glMultiTexCoord4iv(GLenum, const GLint *);
void glMultiTexCoord4s(GLenum, GLshort, GLshort, GLshort, GLshort);
void glMultiTexCoord4sv(GLenum, const GLshort *);
void glLoadTransposeMatrixd(const GLdouble *);
void glLoadTransposeMatrixf(const GLfloat *);
void glMultTransposeMatrixd(const GLdouble *);
void glMultTransposeMatrixf(const GLfloat *);
void glSampleCoverage(GLclampf, GLboolean);
]]
