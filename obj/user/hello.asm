
obj/user/hello：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 00 0e 80 00       	push   $0x800e00
  80003e:	e8 09 01 00 00       	call   80014c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 0e 0e 80 00       	push   $0x800e0e
  800054:	e8 f3 00 00 00       	call   80014c <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 9b 0a 00 00       	call   800b09 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800076:	c1 e0 05             	shl    $0x5,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 db                	test   %ebx,%ebx
  800085:	7e 07                	jle    80008e <libmain+0x30>
		binaryname = argv[0];
  800087:	8b 06                	mov    (%esi),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
  800093:	e8 9b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800098:	e8 0a 00 00 00       	call   8000a7 <exit>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ad:	6a 00                	push   $0x0
  8000af:	e8 14 0a 00 00       	call   800ac8 <sys_env_destroy>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c3:	8b 13                	mov    (%ebx),%edx
  8000c5:	8d 42 01             	lea    0x1(%edx),%eax
  8000c8:	89 03                	mov    %eax,(%ebx)
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d6:	75 1a                	jne    8000f2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	68 ff 00 00 00       	push   $0xff
  8000e0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e3:	50                   	push   %eax
  8000e4:	e8 a2 09 00 00       	call   800a8b <sys_cputs>
		b->idx = 0;
  8000e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ef:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	ff 75 0c             	pushl  0xc(%ebp)
  80011b:	ff 75 08             	pushl  0x8(%ebp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	50                   	push   %eax
  800125:	68 b9 00 80 00       	push   $0x8000b9
  80012a:	e8 1a 01 00 00       	call   800249 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 47 09 00 00       	call   800a8b <sys_cputs>

	return b.cnt;
}
  800144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	50                   	push   %eax
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	e8 9d ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 1c             	sub    $0x1c,%esp
  800169:	89 c7                	mov    %eax,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	8b 55 0c             	mov    0xc(%ebp),%edx
  800173:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800176:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800179:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800181:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800184:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800187:	39 d3                	cmp    %edx,%ebx
  800189:	72 05                	jb     800190 <printnum+0x30>
  80018b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018e:	77 45                	ja     8001d5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	ff 75 18             	pushl  0x18(%ebp)
  800196:	8b 45 14             	mov    0x14(%ebp),%eax
  800199:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019c:	53                   	push   %ebx
  80019d:	ff 75 10             	pushl  0x10(%ebp)
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8001af:	e8 bc 09 00 00       	call   800b70 <__udivdi3>
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	52                   	push   %edx
  8001b8:	50                   	push   %eax
  8001b9:	89 f2                	mov    %esi,%edx
  8001bb:	89 f8                	mov    %edi,%eax
  8001bd:	e8 9e ff ff ff       	call   800160 <printnum>
  8001c2:	83 c4 20             	add    $0x20,%esp
  8001c5:	eb 18                	jmp    8001df <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	56                   	push   %esi
  8001cb:	ff 75 18             	pushl  0x18(%ebp)
  8001ce:	ff d7                	call   *%edi
  8001d0:	83 c4 10             	add    $0x10,%esp
  8001d3:	eb 03                	jmp    8001d8 <printnum+0x78>
  8001d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	7f e8                	jg     8001c7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f2:	e8 a9 0a 00 00       	call   800ca0 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 2f 0e 80 00 	movsbl 0x800e2f(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff d7                	call   *%edi
}
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800215:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	3b 50 04             	cmp    0x4(%eax),%edx
  80021e:	73 0a                	jae    80022a <sprintputch+0x1b>
		*b->buf++ = ch;
  800220:	8d 4a 01             	lea    0x1(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 45 08             	mov    0x8(%ebp),%eax
  800228:	88 02                	mov    %al,(%edx)
}
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800232:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800235:	50                   	push   %eax
  800236:	ff 75 10             	pushl  0x10(%ebp)
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 05 00 00 00       	call   800249 <vprintfmt>
	va_end(ap);
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 2c             	sub    $0x2c,%esp
  800252:	8b 75 08             	mov    0x8(%ebp),%esi
  800255:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800258:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025b:	eb 12                	jmp    80026f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80025d:	85 c0                	test   %eax,%eax
  80025f:	0f 84 36 04 00 00    	je     80069b <vprintfmt+0x452>
				return;
			putch(ch, putdat);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	53                   	push   %ebx
  800269:	50                   	push   %eax
  80026a:	ff d6                	call   *%esi
  80026c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80026f:	83 c7 01             	add    $0x1,%edi
  800272:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800276:	83 f8 25             	cmp    $0x25,%eax
  800279:	75 e2                	jne    80025d <vprintfmt+0x14>
  80027b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80027f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800286:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80028d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800294:	b9 00 00 00 00       	mov    $0x0,%ecx
  800299:	eb 07                	jmp    8002a2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80029b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80029e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a2:	8d 47 01             	lea    0x1(%edi),%eax
  8002a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a8:	0f b6 07             	movzbl (%edi),%eax
  8002ab:	0f b6 d0             	movzbl %al,%edx
  8002ae:	83 e8 23             	sub    $0x23,%eax
  8002b1:	3c 55                	cmp    $0x55,%al
  8002b3:	0f 87 c7 03 00 00    	ja     800680 <vprintfmt+0x437>
  8002b9:	0f b6 c0             	movzbl %al,%eax
  8002bc:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8002c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002c6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ca:	eb d6                	jmp    8002a2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002d7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002da:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002de:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e4:	83 f9 09             	cmp    $0x9,%ecx
  8002e7:	77 3f                	ja     800328 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002e9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002ec:	eb e9                	jmp    8002d7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f1:	8b 00                	mov    (%eax),%eax
  8002f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f9:	8d 40 04             	lea    0x4(%eax),%eax
  8002fc:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800302:	eb 2a                	jmp    80032e <vprintfmt+0xe5>
  800304:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800307:	85 c0                	test   %eax,%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	0f 49 d0             	cmovns %eax,%edx
  800311:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	eb 89                	jmp    8002a2 <vprintfmt+0x59>
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80031c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800323:	e9 7a ff ff ff       	jmp    8002a2 <vprintfmt+0x59>
  800328:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80032b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80032e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800332:	0f 89 6a ff ff ff    	jns    8002a2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800338:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800345:	e9 58 ff ff ff       	jmp    8002a2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80034a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800350:	e9 4d ff ff ff       	jmp    8002a2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800355:	8b 45 14             	mov    0x14(%ebp),%eax
  800358:	8d 78 04             	lea    0x4(%eax),%edi
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	53                   	push   %ebx
  80035f:	ff 30                	pushl  (%eax)
  800361:	ff d6                	call   *%esi
			break;
  800363:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800366:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80036c:	e9 fe fe ff ff       	jmp    80026f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 78 04             	lea    0x4(%eax),%edi
  800377:	8b 00                	mov    (%eax),%eax
  800379:	99                   	cltd   
  80037a:	31 d0                	xor    %edx,%eax
  80037c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037e:	83 f8 07             	cmp    $0x7,%eax
  800381:	7f 0b                	jg     80038e <vprintfmt+0x145>
  800383:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  80038a:	85 d2                	test   %edx,%edx
  80038c:	75 1b                	jne    8003a9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80038e:	50                   	push   %eax
  80038f:	68 47 0e 80 00       	push   $0x800e47
  800394:	53                   	push   %ebx
  800395:	56                   	push   %esi
  800396:	e8 91 fe ff ff       	call   80022c <printfmt>
  80039b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003a4:	e9 c6 fe ff ff       	jmp    80026f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003a9:	52                   	push   %edx
  8003aa:	68 50 0e 80 00       	push   $0x800e50
  8003af:	53                   	push   %ebx
  8003b0:	56                   	push   %esi
  8003b1:	e8 76 fe ff ff       	call   80022c <printfmt>
  8003b6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bf:	e9 ab fe ff ff       	jmp    80026f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	83 c0 04             	add    $0x4,%eax
  8003ca:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d2:	85 ff                	test   %edi,%edi
  8003d4:	b8 40 0e 80 00       	mov    $0x800e40,%eax
  8003d9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e0:	0f 8e 94 00 00 00    	jle    80047a <vprintfmt+0x231>
  8003e6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ea:	0f 84 98 00 00 00    	je     800488 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f0:	83 ec 08             	sub    $0x8,%esp
  8003f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003f6:	57                   	push   %edi
  8003f7:	e8 27 03 00 00       	call   800723 <strnlen>
  8003fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ff:	29 c1                	sub    %eax,%ecx
  800401:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800404:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800407:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80040b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800411:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	eb 0f                	jmp    800424 <vprintfmt+0x1db>
					putch(padc, putdat);
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	53                   	push   %ebx
  800419:	ff 75 e0             	pushl  -0x20(%ebp)
  80041c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80041e:	83 ef 01             	sub    $0x1,%edi
  800421:	83 c4 10             	add    $0x10,%esp
  800424:	85 ff                	test   %edi,%edi
  800426:	7f ed                	jg     800415 <vprintfmt+0x1cc>
  800428:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80042b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80042e:	85 c9                	test   %ecx,%ecx
  800430:	b8 00 00 00 00       	mov    $0x0,%eax
  800435:	0f 49 c1             	cmovns %ecx,%eax
  800438:	29 c1                	sub    %eax,%ecx
  80043a:	89 75 08             	mov    %esi,0x8(%ebp)
  80043d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800440:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800443:	89 cb                	mov    %ecx,%ebx
  800445:	eb 4d                	jmp    800494 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800447:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044b:	74 1b                	je     800468 <vprintfmt+0x21f>
  80044d:	0f be c0             	movsbl %al,%eax
  800450:	83 e8 20             	sub    $0x20,%eax
  800453:	83 f8 5e             	cmp    $0x5e,%eax
  800456:	76 10                	jbe    800468 <vprintfmt+0x21f>
					putch('?', putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 0c             	pushl  0xc(%ebp)
  80045e:	6a 3f                	push   $0x3f
  800460:	ff 55 08             	call   *0x8(%ebp)
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	eb 0d                	jmp    800475 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	ff 75 0c             	pushl  0xc(%ebp)
  80046e:	52                   	push   %edx
  80046f:	ff 55 08             	call   *0x8(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800475:	83 eb 01             	sub    $0x1,%ebx
  800478:	eb 1a                	jmp    800494 <vprintfmt+0x24b>
  80047a:	89 75 08             	mov    %esi,0x8(%ebp)
  80047d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800480:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800483:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800486:	eb 0c                	jmp    800494 <vprintfmt+0x24b>
  800488:	89 75 08             	mov    %esi,0x8(%ebp)
  80048b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800491:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800494:	83 c7 01             	add    $0x1,%edi
  800497:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049b:	0f be d0             	movsbl %al,%edx
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	74 23                	je     8004c5 <vprintfmt+0x27c>
  8004a2:	85 f6                	test   %esi,%esi
  8004a4:	78 a1                	js     800447 <vprintfmt+0x1fe>
  8004a6:	83 ee 01             	sub    $0x1,%esi
  8004a9:	79 9c                	jns    800447 <vprintfmt+0x1fe>
  8004ab:	89 df                	mov    %ebx,%edi
  8004ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b3:	eb 18                	jmp    8004cd <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	53                   	push   %ebx
  8004b9:	6a 20                	push   $0x20
  8004bb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004bd:	83 ef 01             	sub    $0x1,%edi
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	eb 08                	jmp    8004cd <vprintfmt+0x284>
  8004c5:	89 df                	mov    %ebx,%edi
  8004c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	7f e4                	jg     8004b5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	e9 90 fd ff ff       	jmp    80026f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004df:	83 f9 01             	cmp    $0x1,%ecx
  8004e2:	7e 19                	jle    8004fd <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8b 50 04             	mov    0x4(%eax),%edx
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 40 08             	lea    0x8(%eax),%eax
  8004f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fb:	eb 38                	jmp    800535 <vprintfmt+0x2ec>
	else if (lflag)
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	74 1b                	je     80051c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8b 00                	mov    (%eax),%eax
  800506:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800509:	89 c1                	mov    %eax,%ecx
  80050b:	c1 f9 1f             	sar    $0x1f,%ecx
  80050e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 40 04             	lea    0x4(%eax),%eax
  800517:	89 45 14             	mov    %eax,0x14(%ebp)
  80051a:	eb 19                	jmp    800535 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800524:	89 c1                	mov    %eax,%ecx
  800526:	c1 f9 1f             	sar    $0x1f,%ecx
  800529:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 40 04             	lea    0x4(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800535:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800538:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80053b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800540:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800544:	0f 89 02 01 00 00    	jns    80064c <vprintfmt+0x403>
				putch('-', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 2d                	push   $0x2d
  800550:	ff d6                	call   *%esi
				num = -(long long) num;
  800552:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800555:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800558:	f7 da                	neg    %edx
  80055a:	83 d1 00             	adc    $0x0,%ecx
  80055d:	f7 d9                	neg    %ecx
  80055f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
  800567:	e9 e0 00 00 00       	jmp    80064c <vprintfmt+0x403>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 f9 01             	cmp    $0x1,%ecx
  80056f:	7e 18                	jle    800589 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 10                	mov    (%eax),%edx
  800576:	8b 48 04             	mov    0x4(%eax),%ecx
  800579:	8d 40 08             	lea    0x8(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80057f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800584:	e9 c3 00 00 00       	jmp    80064c <vprintfmt+0x403>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800589:	85 c9                	test   %ecx,%ecx
  80058b:	74 1a                	je     8005a7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	b9 00 00 00 00       	mov    $0x0,%ecx
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a2:	e9 a5 00 00 00       	jmp    80064c <vprintfmt+0x403>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b1:	8d 40 04             	lea    0x4(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bc:	e9 8b 00 00 00       	jmp    80064c <vprintfmt+0x403>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('0', putdat);
			num = (unsigned long long)
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d1:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005d6:	eb 74                	jmp    80064c <vprintfmt+0x403>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	6a 30                	push   $0x30
  8005de:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e0:	83 c4 08             	add    $0x8,%esp
  8005e3:	53                   	push   %ebx
  8005e4:	6a 78                	push   $0x78
  8005e6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f2:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005fb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800600:	eb 4a                	jmp    80064c <vprintfmt+0x403>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800602:	83 f9 01             	cmp    $0x1,%ecx
  800605:	7e 15                	jle    80061c <vprintfmt+0x3d3>
		return va_arg(*ap, unsigned long long);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	8b 48 04             	mov    0x4(%eax),%ecx
  80060f:	8d 40 08             	lea    0x8(%eax),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800615:	b8 10 00 00 00       	mov    $0x10,%eax
  80061a:	eb 30                	jmp    80064c <vprintfmt+0x403>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	74 17                	je     800637 <vprintfmt+0x3ee>
		return va_arg(*ap, unsigned long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800630:	b8 10 00 00 00       	mov    $0x10,%eax
  800635:	eb 15                	jmp    80064c <vprintfmt+0x403>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800641:	8d 40 04             	lea    0x4(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800653:	57                   	push   %edi
  800654:	ff 75 e0             	pushl  -0x20(%ebp)
  800657:	50                   	push   %eax
  800658:	51                   	push   %ecx
  800659:	52                   	push   %edx
  80065a:	89 da                	mov    %ebx,%edx
  80065c:	89 f0                	mov    %esi,%eax
  80065e:	e8 fd fa ff ff       	call   800160 <printnum>
			break;
  800663:	83 c4 20             	add    $0x20,%esp
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800669:	e9 01 fc ff ff       	jmp    80026f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	52                   	push   %edx
  800673:	ff d6                	call   *%esi
			break;
  800675:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800678:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067b:	e9 ef fb ff ff       	jmp    80026f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 25                	push   $0x25
  800686:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 03                	jmp    800690 <vprintfmt+0x447>
  80068d:	83 ef 01             	sub    $0x1,%edi
  800690:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800694:	75 f7                	jne    80068d <vprintfmt+0x444>
  800696:	e9 d4 fb ff ff       	jmp    80026f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80069b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069e:	5b                   	pop    %ebx
  80069f:	5e                   	pop    %esi
  8006a0:	5f                   	pop    %edi
  8006a1:	5d                   	pop    %ebp
  8006a2:	c3                   	ret    

008006a3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	83 ec 18             	sub    $0x18,%esp
  8006a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	74 26                	je     8006ea <vsnprintf+0x47>
  8006c4:	85 d2                	test   %edx,%edx
  8006c6:	7e 22                	jle    8006ea <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c8:	ff 75 14             	pushl  0x14(%ebp)
  8006cb:	ff 75 10             	pushl  0x10(%ebp)
  8006ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d1:	50                   	push   %eax
  8006d2:	68 0f 02 80 00       	push   $0x80020f
  8006d7:	e8 6d fb ff ff       	call   800249 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 05                	jmp    8006ef <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fa:	50                   	push   %eax
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	ff 75 08             	pushl  0x8(%ebp)
  800704:	e8 9a ff ff ff       	call   8006a3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800711:	b8 00 00 00 00       	mov    $0x0,%eax
  800716:	eb 03                	jmp    80071b <strlen+0x10>
		n++;
  800718:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071f:	75 f7                	jne    800718 <strlen+0xd>
		n++;
	return n;
}
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800729:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072c:	ba 00 00 00 00       	mov    $0x0,%edx
  800731:	eb 03                	jmp    800736 <strnlen+0x13>
		n++;
  800733:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800736:	39 c2                	cmp    %eax,%edx
  800738:	74 08                	je     800742 <strnlen+0x1f>
  80073a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073e:	75 f3                	jne    800733 <strnlen+0x10>
  800740:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	53                   	push   %ebx
  800748:	8b 45 08             	mov    0x8(%ebp),%eax
  80074b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074e:	89 c2                	mov    %eax,%edx
  800750:	83 c2 01             	add    $0x1,%edx
  800753:	83 c1 01             	add    $0x1,%ecx
  800756:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80075a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075d:	84 db                	test   %bl,%bl
  80075f:	75 ef                	jne    800750 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800761:	5b                   	pop    %ebx
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	53                   	push   %ebx
  800768:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076b:	53                   	push   %ebx
  80076c:	e8 9a ff ff ff       	call   80070b <strlen>
  800771:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	01 d8                	add    %ebx,%eax
  800779:	50                   	push   %eax
  80077a:	e8 c5 ff ff ff       	call   800744 <strcpy>
	return dst;
}
  80077f:	89 d8                	mov    %ebx,%eax
  800781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	56                   	push   %esi
  80078a:	53                   	push   %ebx
  80078b:	8b 75 08             	mov    0x8(%ebp),%esi
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	89 f3                	mov    %esi,%ebx
  800793:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800796:	89 f2                	mov    %esi,%edx
  800798:	eb 0f                	jmp    8007a9 <strncpy+0x23>
		*dst++ = *src;
  80079a:	83 c2 01             	add    $0x1,%edx
  80079d:	0f b6 01             	movzbl (%ecx),%eax
  8007a0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a9:	39 da                	cmp    %ebx,%edx
  8007ab:	75 ed                	jne    80079a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ad:	89 f0                	mov    %esi,%eax
  8007af:	5b                   	pop    %ebx
  8007b0:	5e                   	pop    %esi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	56                   	push   %esi
  8007b7:	53                   	push   %ebx
  8007b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007be:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 21                	je     8007e8 <strlcpy+0x35>
  8007c7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cb:	89 f2                	mov    %esi,%edx
  8007cd:	eb 09                	jmp    8007d8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007cf:	83 c2 01             	add    $0x1,%edx
  8007d2:	83 c1 01             	add    $0x1,%ecx
  8007d5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d8:	39 c2                	cmp    %eax,%edx
  8007da:	74 09                	je     8007e5 <strlcpy+0x32>
  8007dc:	0f b6 19             	movzbl (%ecx),%ebx
  8007df:	84 db                	test   %bl,%bl
  8007e1:	75 ec                	jne    8007cf <strlcpy+0x1c>
  8007e3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e8:	29 f0                	sub    %esi,%eax
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f7:	eb 06                	jmp    8007ff <strcmp+0x11>
		p++, q++;
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ff:	0f b6 01             	movzbl (%ecx),%eax
  800802:	84 c0                	test   %al,%al
  800804:	74 04                	je     80080a <strcmp+0x1c>
  800806:	3a 02                	cmp    (%edx),%al
  800808:	74 ef                	je     8007f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080a:	0f b6 c0             	movzbl %al,%eax
  80080d:	0f b6 12             	movzbl (%edx),%edx
  800810:	29 d0                	sub    %edx,%eax
}
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 c3                	mov    %eax,%ebx
  800820:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800823:	eb 06                	jmp    80082b <strncmp+0x17>
		n--, p++, q++;
  800825:	83 c0 01             	add    $0x1,%eax
  800828:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082b:	39 d8                	cmp    %ebx,%eax
  80082d:	74 15                	je     800844 <strncmp+0x30>
  80082f:	0f b6 08             	movzbl (%eax),%ecx
  800832:	84 c9                	test   %cl,%cl
  800834:	74 04                	je     80083a <strncmp+0x26>
  800836:	3a 0a                	cmp    (%edx),%cl
  800838:	74 eb                	je     800825 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083a:	0f b6 00             	movzbl (%eax),%eax
  80083d:	0f b6 12             	movzbl (%edx),%edx
  800840:	29 d0                	sub    %edx,%eax
  800842:	eb 05                	jmp    800849 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800856:	eb 07                	jmp    80085f <strchr+0x13>
		if (*s == c)
  800858:	38 ca                	cmp    %cl,%dl
  80085a:	74 0f                	je     80086b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085c:	83 c0 01             	add    $0x1,%eax
  80085f:	0f b6 10             	movzbl (%eax),%edx
  800862:	84 d2                	test   %dl,%dl
  800864:	75 f2                	jne    800858 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800877:	eb 03                	jmp    80087c <strfind+0xf>
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80087f:	38 ca                	cmp    %cl,%dl
  800881:	74 04                	je     800887 <strfind+0x1a>
  800883:	84 d2                	test   %dl,%dl
  800885:	75 f2                	jne    800879 <strfind+0xc>
			break;
	return (char *) s;
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	57                   	push   %edi
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800892:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800895:	85 c9                	test   %ecx,%ecx
  800897:	74 36                	je     8008cf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800899:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089f:	75 28                	jne    8008c9 <memset+0x40>
  8008a1:	f6 c1 03             	test   $0x3,%cl
  8008a4:	75 23                	jne    8008c9 <memset+0x40>
		c &= 0xFF;
  8008a6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008aa:	89 d3                	mov    %edx,%ebx
  8008ac:	c1 e3 08             	shl    $0x8,%ebx
  8008af:	89 d6                	mov    %edx,%esi
  8008b1:	c1 e6 18             	shl    $0x18,%esi
  8008b4:	89 d0                	mov    %edx,%eax
  8008b6:	c1 e0 10             	shl    $0x10,%eax
  8008b9:	09 f0                	or     %esi,%eax
  8008bb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008bd:	89 d8                	mov    %ebx,%eax
  8008bf:	09 d0                	or     %edx,%eax
  8008c1:	c1 e9 02             	shr    $0x2,%ecx
  8008c4:	fc                   	cld    
  8008c5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c7:	eb 06                	jmp    8008cf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cc:	fc                   	cld    
  8008cd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008cf:	89 f8                	mov    %edi,%eax
  8008d1:	5b                   	pop    %ebx
  8008d2:	5e                   	pop    %esi
  8008d3:	5f                   	pop    %edi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e4:	39 c6                	cmp    %eax,%esi
  8008e6:	73 35                	jae    80091d <memmove+0x47>
  8008e8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008eb:	39 d0                	cmp    %edx,%eax
  8008ed:	73 2e                	jae    80091d <memmove+0x47>
		s += n;
		d += n;
  8008ef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f2:	89 d6                	mov    %edx,%esi
  8008f4:	09 fe                	or     %edi,%esi
  8008f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fc:	75 13                	jne    800911 <memmove+0x3b>
  8008fe:	f6 c1 03             	test   $0x3,%cl
  800901:	75 0e                	jne    800911 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800903:	83 ef 04             	sub    $0x4,%edi
  800906:	8d 72 fc             	lea    -0x4(%edx),%esi
  800909:	c1 e9 02             	shr    $0x2,%ecx
  80090c:	fd                   	std    
  80090d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090f:	eb 09                	jmp    80091a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800911:	83 ef 01             	sub    $0x1,%edi
  800914:	8d 72 ff             	lea    -0x1(%edx),%esi
  800917:	fd                   	std    
  800918:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091a:	fc                   	cld    
  80091b:	eb 1d                	jmp    80093a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091d:	89 f2                	mov    %esi,%edx
  80091f:	09 c2                	or     %eax,%edx
  800921:	f6 c2 03             	test   $0x3,%dl
  800924:	75 0f                	jne    800935 <memmove+0x5f>
  800926:	f6 c1 03             	test   $0x3,%cl
  800929:	75 0a                	jne    800935 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80092b:	c1 e9 02             	shr    $0x2,%ecx
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800933:	eb 05                	jmp    80093a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800935:	89 c7                	mov    %eax,%edi
  800937:	fc                   	cld    
  800938:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800941:	ff 75 10             	pushl  0x10(%ebp)
  800944:	ff 75 0c             	pushl  0xc(%ebp)
  800947:	ff 75 08             	pushl  0x8(%ebp)
  80094a:	e8 87 ff ff ff       	call   8008d6 <memmove>
}
  80094f:	c9                   	leave  
  800950:	c3                   	ret    

00800951 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	89 c6                	mov    %eax,%esi
  80095e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800961:	eb 1a                	jmp    80097d <memcmp+0x2c>
		if (*s1 != *s2)
  800963:	0f b6 08             	movzbl (%eax),%ecx
  800966:	0f b6 1a             	movzbl (%edx),%ebx
  800969:	38 d9                	cmp    %bl,%cl
  80096b:	74 0a                	je     800977 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80096d:	0f b6 c1             	movzbl %cl,%eax
  800970:	0f b6 db             	movzbl %bl,%ebx
  800973:	29 d8                	sub    %ebx,%eax
  800975:	eb 0f                	jmp    800986 <memcmp+0x35>
		s1++, s2++;
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097d:	39 f0                	cmp    %esi,%eax
  80097f:	75 e2                	jne    800963 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	53                   	push   %ebx
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800991:	89 c1                	mov    %eax,%ecx
  800993:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800996:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099a:	eb 0a                	jmp    8009a6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099c:	0f b6 10             	movzbl (%eax),%edx
  80099f:	39 da                	cmp    %ebx,%edx
  8009a1:	74 07                	je     8009aa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	39 c8                	cmp    %ecx,%eax
  8009a8:	72 f2                	jb     80099c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	57                   	push   %edi
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b9:	eb 03                	jmp    8009be <strtol+0x11>
		s++;
  8009bb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009be:	0f b6 01             	movzbl (%ecx),%eax
  8009c1:	3c 20                	cmp    $0x20,%al
  8009c3:	74 f6                	je     8009bb <strtol+0xe>
  8009c5:	3c 09                	cmp    $0x9,%al
  8009c7:	74 f2                	je     8009bb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c9:	3c 2b                	cmp    $0x2b,%al
  8009cb:	75 0a                	jne    8009d7 <strtol+0x2a>
		s++;
  8009cd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d5:	eb 11                	jmp    8009e8 <strtol+0x3b>
  8009d7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009dc:	3c 2d                	cmp    $0x2d,%al
  8009de:	75 08                	jne    8009e8 <strtol+0x3b>
		s++, neg = 1;
  8009e0:	83 c1 01             	add    $0x1,%ecx
  8009e3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ee:	75 15                	jne    800a05 <strtol+0x58>
  8009f0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f3:	75 10                	jne    800a05 <strtol+0x58>
  8009f5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f9:	75 7c                	jne    800a77 <strtol+0xca>
		s += 2, base = 16;
  8009fb:	83 c1 02             	add    $0x2,%ecx
  8009fe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a03:	eb 16                	jmp    800a1b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a05:	85 db                	test   %ebx,%ebx
  800a07:	75 12                	jne    800a1b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a09:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a11:	75 08                	jne    800a1b <strtol+0x6e>
		s++, base = 8;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a23:	0f b6 11             	movzbl (%ecx),%edx
  800a26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a29:	89 f3                	mov    %esi,%ebx
  800a2b:	80 fb 09             	cmp    $0x9,%bl
  800a2e:	77 08                	ja     800a38 <strtol+0x8b>
			dig = *s - '0';
  800a30:	0f be d2             	movsbl %dl,%edx
  800a33:	83 ea 30             	sub    $0x30,%edx
  800a36:	eb 22                	jmp    800a5a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a38:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	80 fb 19             	cmp    $0x19,%bl
  800a40:	77 08                	ja     800a4a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a42:	0f be d2             	movsbl %dl,%edx
  800a45:	83 ea 57             	sub    $0x57,%edx
  800a48:	eb 10                	jmp    800a5a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a4a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4d:	89 f3                	mov    %esi,%ebx
  800a4f:	80 fb 19             	cmp    $0x19,%bl
  800a52:	77 16                	ja     800a6a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a54:	0f be d2             	movsbl %dl,%edx
  800a57:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a5a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5d:	7d 0b                	jge    800a6a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a5f:	83 c1 01             	add    $0x1,%ecx
  800a62:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a66:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a68:	eb b9                	jmp    800a23 <strtol+0x76>

	if (endptr)
  800a6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6e:	74 0d                	je     800a7d <strtol+0xd0>
		*endptr = (char *) s;
  800a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a73:	89 0e                	mov    %ecx,(%esi)
  800a75:	eb 06                	jmp    800a7d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	74 98                	je     800a13 <strtol+0x66>
  800a7b:	eb 9e                	jmp    800a1b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7d:	89 c2                	mov    %eax,%edx
  800a7f:	f7 da                	neg    %edx
  800a81:	85 ff                	test   %edi,%edi
  800a83:	0f 45 c2             	cmovne %edx,%eax
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a99:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9c:	89 c3                	mov    %eax,%ebx
  800a9e:	89 c7                	mov    %eax,%edi
  800aa0:	89 c6                	mov    %eax,%esi
  800aa2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab9:	89 d1                	mov    %edx,%ecx
  800abb:	89 d3                	mov    %edx,%ebx
  800abd:	89 d7                	mov    %edx,%edi
  800abf:	89 d6                	mov    %edx,%esi
  800ac1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad6:	b8 03 00 00 00       	mov    $0x3,%eax
  800adb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ade:	89 cb                	mov    %ecx,%ebx
  800ae0:	89 cf                	mov    %ecx,%edi
  800ae2:	89 ce                	mov    %ecx,%esi
  800ae4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	7e 17                	jle    800b01 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aea:	83 ec 0c             	sub    $0xc,%esp
  800aed:	50                   	push   %eax
  800aee:	6a 03                	push   $0x3
  800af0:	68 40 10 80 00       	push   $0x801040
  800af5:	6a 23                	push   $0x23
  800af7:	68 5d 10 80 00       	push   $0x80105d
  800afc:	e8 27 00 00 00       	call   800b28 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b14:	b8 02 00 00 00       	mov    $0x2,%eax
  800b19:	89 d1                	mov    %edx,%ecx
  800b1b:	89 d3                	mov    %edx,%ebx
  800b1d:	89 d7                	mov    %edx,%edi
  800b1f:	89 d6                	mov    %edx,%esi
  800b21:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b2d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b30:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b36:	e8 ce ff ff ff       	call   800b09 <sys_getenvid>
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	ff 75 0c             	pushl  0xc(%ebp)
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	56                   	push   %esi
  800b45:	50                   	push   %eax
  800b46:	68 6c 10 80 00       	push   $0x80106c
  800b4b:	e8 fc f5 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b50:	83 c4 18             	add    $0x18,%esp
  800b53:	53                   	push   %ebx
  800b54:	ff 75 10             	pushl  0x10(%ebp)
  800b57:	e8 9f f5 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800b5c:	c7 04 24 0c 0e 80 00 	movl   $0x800e0c,(%esp)
  800b63:	e8 e4 f5 ff ff       	call   80014c <cprintf>
  800b68:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b6b:	cc                   	int3   
  800b6c:	eb fd                	jmp    800b6b <_panic+0x43>
  800b6e:	66 90                	xchg   %ax,%ax

00800b70 <__udivdi3>:
  800b70:	55                   	push   %ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 1c             	sub    $0x1c,%esp
  800b77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b87:	85 f6                	test   %esi,%esi
  800b89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b8d:	89 ca                	mov    %ecx,%edx
  800b8f:	89 f8                	mov    %edi,%eax
  800b91:	75 3d                	jne    800bd0 <__udivdi3+0x60>
  800b93:	39 cf                	cmp    %ecx,%edi
  800b95:	0f 87 c5 00 00 00    	ja     800c60 <__udivdi3+0xf0>
  800b9b:	85 ff                	test   %edi,%edi
  800b9d:	89 fd                	mov    %edi,%ebp
  800b9f:	75 0b                	jne    800bac <__udivdi3+0x3c>
  800ba1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba6:	31 d2                	xor    %edx,%edx
  800ba8:	f7 f7                	div    %edi
  800baa:	89 c5                	mov    %eax,%ebp
  800bac:	89 c8                	mov    %ecx,%eax
  800bae:	31 d2                	xor    %edx,%edx
  800bb0:	f7 f5                	div    %ebp
  800bb2:	89 c1                	mov    %eax,%ecx
  800bb4:	89 d8                	mov    %ebx,%eax
  800bb6:	89 cf                	mov    %ecx,%edi
  800bb8:	f7 f5                	div    %ebp
  800bba:	89 c3                	mov    %eax,%ebx
  800bbc:	89 d8                	mov    %ebx,%eax
  800bbe:	89 fa                	mov    %edi,%edx
  800bc0:	83 c4 1c             	add    $0x1c,%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    
  800bc8:	90                   	nop
  800bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bd0:	39 ce                	cmp    %ecx,%esi
  800bd2:	77 74                	ja     800c48 <__udivdi3+0xd8>
  800bd4:	0f bd fe             	bsr    %esi,%edi
  800bd7:	83 f7 1f             	xor    $0x1f,%edi
  800bda:	0f 84 98 00 00 00    	je     800c78 <__udivdi3+0x108>
  800be0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800be5:	89 f9                	mov    %edi,%ecx
  800be7:	89 c5                	mov    %eax,%ebp
  800be9:	29 fb                	sub    %edi,%ebx
  800beb:	d3 e6                	shl    %cl,%esi
  800bed:	89 d9                	mov    %ebx,%ecx
  800bef:	d3 ed                	shr    %cl,%ebp
  800bf1:	89 f9                	mov    %edi,%ecx
  800bf3:	d3 e0                	shl    %cl,%eax
  800bf5:	09 ee                	or     %ebp,%esi
  800bf7:	89 d9                	mov    %ebx,%ecx
  800bf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bfd:	89 d5                	mov    %edx,%ebp
  800bff:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c03:	d3 ed                	shr    %cl,%ebp
  800c05:	89 f9                	mov    %edi,%ecx
  800c07:	d3 e2                	shl    %cl,%edx
  800c09:	89 d9                	mov    %ebx,%ecx
  800c0b:	d3 e8                	shr    %cl,%eax
  800c0d:	09 c2                	or     %eax,%edx
  800c0f:	89 d0                	mov    %edx,%eax
  800c11:	89 ea                	mov    %ebp,%edx
  800c13:	f7 f6                	div    %esi
  800c15:	89 d5                	mov    %edx,%ebp
  800c17:	89 c3                	mov    %eax,%ebx
  800c19:	f7 64 24 0c          	mull   0xc(%esp)
  800c1d:	39 d5                	cmp    %edx,%ebp
  800c1f:	72 10                	jb     800c31 <__udivdi3+0xc1>
  800c21:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c25:	89 f9                	mov    %edi,%ecx
  800c27:	d3 e6                	shl    %cl,%esi
  800c29:	39 c6                	cmp    %eax,%esi
  800c2b:	73 07                	jae    800c34 <__udivdi3+0xc4>
  800c2d:	39 d5                	cmp    %edx,%ebp
  800c2f:	75 03                	jne    800c34 <__udivdi3+0xc4>
  800c31:	83 eb 01             	sub    $0x1,%ebx
  800c34:	31 ff                	xor    %edi,%edi
  800c36:	89 d8                	mov    %ebx,%eax
  800c38:	89 fa                	mov    %edi,%edx
  800c3a:	83 c4 1c             	add    $0x1c,%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    
  800c42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c48:	31 ff                	xor    %edi,%edi
  800c4a:	31 db                	xor    %ebx,%ebx
  800c4c:	89 d8                	mov    %ebx,%eax
  800c4e:	89 fa                	mov    %edi,%edx
  800c50:	83 c4 1c             	add    $0x1c,%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    
  800c58:	90                   	nop
  800c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c60:	89 d8                	mov    %ebx,%eax
  800c62:	f7 f7                	div    %edi
  800c64:	31 ff                	xor    %edi,%edi
  800c66:	89 c3                	mov    %eax,%ebx
  800c68:	89 d8                	mov    %ebx,%eax
  800c6a:	89 fa                	mov    %edi,%edx
  800c6c:	83 c4 1c             	add    $0x1c,%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    
  800c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c78:	39 ce                	cmp    %ecx,%esi
  800c7a:	72 0c                	jb     800c88 <__udivdi3+0x118>
  800c7c:	31 db                	xor    %ebx,%ebx
  800c7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c82:	0f 87 34 ff ff ff    	ja     800bbc <__udivdi3+0x4c>
  800c88:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c8d:	e9 2a ff ff ff       	jmp    800bbc <__udivdi3+0x4c>
  800c92:	66 90                	xchg   %ax,%ax
  800c94:	66 90                	xchg   %ax,%ax
  800c96:	66 90                	xchg   %ax,%ax
  800c98:	66 90                	xchg   %ax,%ax
  800c9a:	66 90                	xchg   %ax,%ax
  800c9c:	66 90                	xchg   %ax,%ax
  800c9e:	66 90                	xchg   %ax,%ax

00800ca0 <__umoddi3>:
  800ca0:	55                   	push   %ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 1c             	sub    $0x1c,%esp
  800ca7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800caf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800cb7:	85 d2                	test   %edx,%edx
  800cb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	89 f3                	mov    %esi,%ebx
  800cc3:	89 3c 24             	mov    %edi,(%esp)
  800cc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cca:	75 1c                	jne    800ce8 <__umoddi3+0x48>
  800ccc:	39 f7                	cmp    %esi,%edi
  800cce:	76 50                	jbe    800d20 <__umoddi3+0x80>
  800cd0:	89 c8                	mov    %ecx,%eax
  800cd2:	89 f2                	mov    %esi,%edx
  800cd4:	f7 f7                	div    %edi
  800cd6:	89 d0                	mov    %edx,%eax
  800cd8:	31 d2                	xor    %edx,%edx
  800cda:	83 c4 1c             	add    $0x1c,%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
  800ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ce8:	39 f2                	cmp    %esi,%edx
  800cea:	89 d0                	mov    %edx,%eax
  800cec:	77 52                	ja     800d40 <__umoddi3+0xa0>
  800cee:	0f bd ea             	bsr    %edx,%ebp
  800cf1:	83 f5 1f             	xor    $0x1f,%ebp
  800cf4:	75 5a                	jne    800d50 <__umoddi3+0xb0>
  800cf6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cfa:	0f 82 e0 00 00 00    	jb     800de0 <__umoddi3+0x140>
  800d00:	39 0c 24             	cmp    %ecx,(%esp)
  800d03:	0f 86 d7 00 00 00    	jbe    800de0 <__umoddi3+0x140>
  800d09:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d11:	83 c4 1c             	add    $0x1c,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    
  800d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d20:	85 ff                	test   %edi,%edi
  800d22:	89 fd                	mov    %edi,%ebp
  800d24:	75 0b                	jne    800d31 <__umoddi3+0x91>
  800d26:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	f7 f7                	div    %edi
  800d2f:	89 c5                	mov    %eax,%ebp
  800d31:	89 f0                	mov    %esi,%eax
  800d33:	31 d2                	xor    %edx,%edx
  800d35:	f7 f5                	div    %ebp
  800d37:	89 c8                	mov    %ecx,%eax
  800d39:	f7 f5                	div    %ebp
  800d3b:	89 d0                	mov    %edx,%eax
  800d3d:	eb 99                	jmp    800cd8 <__umoddi3+0x38>
  800d3f:	90                   	nop
  800d40:	89 c8                	mov    %ecx,%eax
  800d42:	89 f2                	mov    %esi,%edx
  800d44:	83 c4 1c             	add    $0x1c,%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    
  800d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d50:	8b 34 24             	mov    (%esp),%esi
  800d53:	bf 20 00 00 00       	mov    $0x20,%edi
  800d58:	89 e9                	mov    %ebp,%ecx
  800d5a:	29 ef                	sub    %ebp,%edi
  800d5c:	d3 e0                	shl    %cl,%eax
  800d5e:	89 f9                	mov    %edi,%ecx
  800d60:	89 f2                	mov    %esi,%edx
  800d62:	d3 ea                	shr    %cl,%edx
  800d64:	89 e9                	mov    %ebp,%ecx
  800d66:	09 c2                	or     %eax,%edx
  800d68:	89 d8                	mov    %ebx,%eax
  800d6a:	89 14 24             	mov    %edx,(%esp)
  800d6d:	89 f2                	mov    %esi,%edx
  800d6f:	d3 e2                	shl    %cl,%edx
  800d71:	89 f9                	mov    %edi,%ecx
  800d73:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d7b:	d3 e8                	shr    %cl,%eax
  800d7d:	89 e9                	mov    %ebp,%ecx
  800d7f:	89 c6                	mov    %eax,%esi
  800d81:	d3 e3                	shl    %cl,%ebx
  800d83:	89 f9                	mov    %edi,%ecx
  800d85:	89 d0                	mov    %edx,%eax
  800d87:	d3 e8                	shr    %cl,%eax
  800d89:	89 e9                	mov    %ebp,%ecx
  800d8b:	09 d8                	or     %ebx,%eax
  800d8d:	89 d3                	mov    %edx,%ebx
  800d8f:	89 f2                	mov    %esi,%edx
  800d91:	f7 34 24             	divl   (%esp)
  800d94:	89 d6                	mov    %edx,%esi
  800d96:	d3 e3                	shl    %cl,%ebx
  800d98:	f7 64 24 04          	mull   0x4(%esp)
  800d9c:	39 d6                	cmp    %edx,%esi
  800d9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800da2:	89 d1                	mov    %edx,%ecx
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	72 08                	jb     800db0 <__umoddi3+0x110>
  800da8:	75 11                	jne    800dbb <__umoddi3+0x11b>
  800daa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dae:	73 0b                	jae    800dbb <__umoddi3+0x11b>
  800db0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800db4:	1b 14 24             	sbb    (%esp),%edx
  800db7:	89 d1                	mov    %edx,%ecx
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800dbf:	29 da                	sub    %ebx,%edx
  800dc1:	19 ce                	sbb    %ecx,%esi
  800dc3:	89 f9                	mov    %edi,%ecx
  800dc5:	89 f0                	mov    %esi,%eax
  800dc7:	d3 e0                	shl    %cl,%eax
  800dc9:	89 e9                	mov    %ebp,%ecx
  800dcb:	d3 ea                	shr    %cl,%edx
  800dcd:	89 e9                	mov    %ebp,%ecx
  800dcf:	d3 ee                	shr    %cl,%esi
  800dd1:	09 d0                	or     %edx,%eax
  800dd3:	89 f2                	mov    %esi,%edx
  800dd5:	83 c4 1c             	add    $0x1c,%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    
  800ddd:	8d 76 00             	lea    0x0(%esi),%esi
  800de0:	29 f9                	sub    %edi,%ecx
  800de2:	19 d6                	sbb    %edx,%esi
  800de4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800de8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dec:	e9 18 ff ff ff       	jmp    800d09 <__umoddi3+0x69>
