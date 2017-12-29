
obj/user/breakpoint：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 c9 00 00 00       	call   800112 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800051:	c1 e0 05             	shl    $0x5,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 0a 00 00 00       	call   800082 <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800088:	6a 00                	push   $0x0
  80008a:	e8 42 00 00 00       	call   8000d1 <sys_env_destroy>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	57                   	push   %edi
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009a:	b8 00 00 00 00       	mov    $0x0,%eax
  80009f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a5:	89 c3                	mov    %eax,%ebx
  8000a7:	89 c7                	mov    %eax,%edi
  8000a9:	89 c6                	mov    %eax,%esi
  8000ab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5f                   	pop    %edi
  8000b0:	5d                   	pop    %ebp
  8000b1:	c3                   	ret    

008000b2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	57                   	push   %edi
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c2:	89 d1                	mov    %edx,%ecx
  8000c4:	89 d3                	mov    %edx,%ebx
  8000c6:	89 d7                	mov    %edx,%edi
  8000c8:	89 d6                	mov    %edx,%esi
  8000ca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000df:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	89 cb                	mov    %ecx,%ebx
  8000e9:	89 cf                	mov    %ecx,%edi
  8000eb:	89 ce                	mov    %ecx,%esi
  8000ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ef:	85 c0                	test   %eax,%eax
  8000f1:	7e 17                	jle    80010a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	50                   	push   %eax
  8000f7:	6a 03                	push   $0x3
  8000f9:	68 ea 0d 80 00       	push   $0x800dea
  8000fe:	6a 23                	push   $0x23
  800100:	68 07 0e 80 00       	push   $0x800e07
  800105:	e8 27 00 00 00       	call   800131 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5f                   	pop    %edi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	57                   	push   %edi
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	b8 02 00 00 00       	mov    $0x2,%eax
  800122:	89 d1                	mov    %edx,%ecx
  800124:	89 d3                	mov    %edx,%ebx
  800126:	89 d7                	mov    %edx,%edi
  800128:	89 d6                	mov    %edx,%esi
  80012a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	56                   	push   %esi
  800135:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800136:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800139:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013f:	e8 ce ff ff ff       	call   800112 <sys_getenvid>
  800144:	83 ec 0c             	sub    $0xc,%esp
  800147:	ff 75 0c             	pushl  0xc(%ebp)
  80014a:	ff 75 08             	pushl  0x8(%ebp)
  80014d:	56                   	push   %esi
  80014e:	50                   	push   %eax
  80014f:	68 18 0e 80 00       	push   $0x800e18
  800154:	e8 b1 00 00 00       	call   80020a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800159:	83 c4 18             	add    $0x18,%esp
  80015c:	53                   	push   %ebx
  80015d:	ff 75 10             	pushl  0x10(%ebp)
  800160:	e8 54 00 00 00       	call   8001b9 <vcprintf>
	cprintf("\n");
  800165:	c7 04 24 3c 0e 80 00 	movl   $0x800e3c,(%esp)
  80016c:	e8 99 00 00 00       	call   80020a <cprintf>
  800171:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800174:	cc                   	int3   
  800175:	eb fd                	jmp    800174 <_panic+0x43>

00800177 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	83 ec 04             	sub    $0x4,%esp
  80017e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800181:	8b 13                	mov    (%ebx),%edx
  800183:	8d 42 01             	lea    0x1(%edx),%eax
  800186:	89 03                	mov    %eax,(%ebx)
  800188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800194:	75 1a                	jne    8001b0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	68 ff 00 00 00       	push   $0xff
  80019e:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a1:	50                   	push   %eax
  8001a2:	e8 ed fe ff ff       	call   800094 <sys_cputs>
		b->idx = 0;
  8001a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ad:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c9:	00 00 00 
	b.cnt = 0;
  8001cc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d6:	ff 75 0c             	pushl  0xc(%ebp)
  8001d9:	ff 75 08             	pushl  0x8(%ebp)
  8001dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	68 77 01 80 00       	push   $0x800177
  8001e8:	e8 1a 01 00 00       	call   800307 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ed:	83 c4 08             	add    $0x8,%esp
  8001f0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 92 fe ff ff       	call   800094 <sys_cputs>

	return b.cnt;
}
  800202:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800210:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800213:	50                   	push   %eax
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	e8 9d ff ff ff       	call   8001b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	57                   	push   %edi
  800222:	56                   	push   %esi
  800223:	53                   	push   %ebx
  800224:	83 ec 1c             	sub    $0x1c,%esp
  800227:	89 c7                	mov    %eax,%edi
  800229:	89 d6                	mov    %edx,%esi
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800237:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800242:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800245:	39 d3                	cmp    %edx,%ebx
  800247:	72 05                	jb     80024e <printnum+0x30>
  800249:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024c:	77 45                	ja     800293 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 18             	pushl  0x18(%ebp)
  800254:	8b 45 14             	mov    0x14(%ebp),%eax
  800257:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025a:	53                   	push   %ebx
  80025b:	ff 75 10             	pushl  0x10(%ebp)
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	ff 75 e4             	pushl  -0x1c(%ebp)
  800264:	ff 75 e0             	pushl  -0x20(%ebp)
  800267:	ff 75 dc             	pushl  -0x24(%ebp)
  80026a:	ff 75 d8             	pushl  -0x28(%ebp)
  80026d:	e8 de 08 00 00       	call   800b50 <__udivdi3>
  800272:	83 c4 18             	add    $0x18,%esp
  800275:	52                   	push   %edx
  800276:	50                   	push   %eax
  800277:	89 f2                	mov    %esi,%edx
  800279:	89 f8                	mov    %edi,%eax
  80027b:	e8 9e ff ff ff       	call   80021e <printnum>
  800280:	83 c4 20             	add    $0x20,%esp
  800283:	eb 18                	jmp    80029d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	ff 75 18             	pushl  0x18(%ebp)
  80028c:	ff d7                	call   *%edi
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	eb 03                	jmp    800296 <printnum+0x78>
  800293:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800296:	83 eb 01             	sub    $0x1,%ebx
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f e8                	jg     800285 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 cb 09 00 00       	call   800c80 <__umoddi3>
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	0f be 80 3e 0e 80 00 	movsbl 0x800e3e(%eax),%eax
  8002bf:	50                   	push   %eax
  8002c0:	ff d7                	call   *%edi
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dc:	73 0a                	jae    8002e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	88 02                	mov    %al,(%edx)
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	50                   	push   %eax
  8002f4:	ff 75 10             	pushl  0x10(%ebp)
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	e8 05 00 00 00       	call   800307 <vprintfmt>
	va_end(ap);
}
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	57                   	push   %edi
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
  80030d:	83 ec 2c             	sub    $0x2c,%esp
  800310:	8b 75 08             	mov    0x8(%ebp),%esi
  800313:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800316:	8b 7d 10             	mov    0x10(%ebp),%edi
  800319:	eb 12                	jmp    80032d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031b:	85 c0                	test   %eax,%eax
  80031d:	0f 84 36 04 00 00    	je     800759 <vprintfmt+0x452>
				return;
			putch(ch, putdat);
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	53                   	push   %ebx
  800327:	50                   	push   %eax
  800328:	ff d6                	call   *%esi
  80032a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032d:	83 c7 01             	add    $0x1,%edi
  800330:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800334:	83 f8 25             	cmp    $0x25,%eax
  800337:	75 e2                	jne    80031b <vprintfmt+0x14>
  800339:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80033d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800344:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	eb 07                	jmp    800360 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8d 47 01             	lea    0x1(%edi),%eax
  800363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800366:	0f b6 07             	movzbl (%edi),%eax
  800369:	0f b6 d0             	movzbl %al,%edx
  80036c:	83 e8 23             	sub    $0x23,%eax
  80036f:	3c 55                	cmp    $0x55,%al
  800371:	0f 87 c7 03 00 00    	ja     80073e <vprintfmt+0x437>
  800377:	0f b6 c0             	movzbl %al,%eax
  80037a:	ff 24 85 e0 0e 80 00 	jmp    *0x800ee0(,%eax,4)
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800384:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800388:	eb d6                	jmp    800360 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038d:	b8 00 00 00 00       	mov    $0x0,%eax
  800392:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800395:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800398:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a2:	83 f9 09             	cmp    $0x9,%ecx
  8003a5:	77 3f                	ja     8003e6 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003aa:	eb e9                	jmp    800395 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8b 00                	mov    (%eax),%eax
  8003b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 40 04             	lea    0x4(%eax),%eax
  8003ba:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c0:	eb 2a                	jmp    8003ec <vprintfmt+0xe5>
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cc:	0f 49 d0             	cmovns %eax,%edx
  8003cf:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d5:	eb 89                	jmp    800360 <vprintfmt+0x59>
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e1:	e9 7a ff ff ff       	jmp    800360 <vprintfmt+0x59>
  8003e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f0:	0f 89 6a ff ff ff    	jns    800360 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800403:	e9 58 ff ff ff       	jmp    800360 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800408:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040e:	e9 4d ff ff ff       	jmp    800360 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 78 04             	lea    0x4(%eax),%edi
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	53                   	push   %ebx
  80041d:	ff 30                	pushl  (%eax)
  80041f:	ff d6                	call   *%esi
			break;
  800421:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800424:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042a:	e9 fe fe ff ff       	jmp    80032d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 78 04             	lea    0x4(%eax),%edi
  800435:	8b 00                	mov    (%eax),%eax
  800437:	99                   	cltd   
  800438:	31 d0                	xor    %edx,%eax
  80043a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043c:	83 f8 07             	cmp    $0x7,%eax
  80043f:	7f 0b                	jg     80044c <vprintfmt+0x145>
  800441:	8b 14 85 40 10 80 00 	mov    0x801040(,%eax,4),%edx
  800448:	85 d2                	test   %edx,%edx
  80044a:	75 1b                	jne    800467 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80044c:	50                   	push   %eax
  80044d:	68 56 0e 80 00       	push   $0x800e56
  800452:	53                   	push   %ebx
  800453:	56                   	push   %esi
  800454:	e8 91 fe ff ff       	call   8002ea <printfmt>
  800459:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800462:	e9 c6 fe ff ff       	jmp    80032d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800467:	52                   	push   %edx
  800468:	68 5f 0e 80 00       	push   $0x800e5f
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 76 fe ff ff       	call   8002ea <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800477:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047d:	e9 ab fe ff ff       	jmp    80032d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	83 c0 04             	add    $0x4,%eax
  800488:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800490:	85 ff                	test   %edi,%edi
  800492:	b8 4f 0e 80 00       	mov    $0x800e4f,%eax
  800497:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049e:	0f 8e 94 00 00 00    	jle    800538 <vprintfmt+0x231>
  8004a4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a8:	0f 84 98 00 00 00    	je     800546 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b4:	57                   	push   %edi
  8004b5:	e8 27 03 00 00       	call   8007e1 <strnlen>
  8004ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004bd:	29 c1                	sub    %eax,%ecx
  8004bf:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004c2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004cf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	eb 0f                	jmp    8004e2 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004da:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	83 ef 01             	sub    $0x1,%edi
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	85 ff                	test   %edi,%edi
  8004e4:	7f ed                	jg     8004d3 <vprintfmt+0x1cc>
  8004e6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ec:	85 c9                	test   %ecx,%ecx
  8004ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f3:	0f 49 c1             	cmovns %ecx,%eax
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800501:	89 cb                	mov    %ecx,%ebx
  800503:	eb 4d                	jmp    800552 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800505:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800509:	74 1b                	je     800526 <vprintfmt+0x21f>
  80050b:	0f be c0             	movsbl %al,%eax
  80050e:	83 e8 20             	sub    $0x20,%eax
  800511:	83 f8 5e             	cmp    $0x5e,%eax
  800514:	76 10                	jbe    800526 <vprintfmt+0x21f>
					putch('?', putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	6a 3f                	push   $0x3f
  80051e:	ff 55 08             	call   *0x8(%ebp)
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	eb 0d                	jmp    800533 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	ff 75 0c             	pushl  0xc(%ebp)
  80052c:	52                   	push   %edx
  80052d:	ff 55 08             	call   *0x8(%ebp)
  800530:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800533:	83 eb 01             	sub    $0x1,%ebx
  800536:	eb 1a                	jmp    800552 <vprintfmt+0x24b>
  800538:	89 75 08             	mov    %esi,0x8(%ebp)
  80053b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800541:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800544:	eb 0c                	jmp    800552 <vprintfmt+0x24b>
  800546:	89 75 08             	mov    %esi,0x8(%ebp)
  800549:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800552:	83 c7 01             	add    $0x1,%edi
  800555:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800559:	0f be d0             	movsbl %al,%edx
  80055c:	85 d2                	test   %edx,%edx
  80055e:	74 23                	je     800583 <vprintfmt+0x27c>
  800560:	85 f6                	test   %esi,%esi
  800562:	78 a1                	js     800505 <vprintfmt+0x1fe>
  800564:	83 ee 01             	sub    $0x1,%esi
  800567:	79 9c                	jns    800505 <vprintfmt+0x1fe>
  800569:	89 df                	mov    %ebx,%edi
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800571:	eb 18                	jmp    80058b <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	53                   	push   %ebx
  800577:	6a 20                	push   $0x20
  800579:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057b:	83 ef 01             	sub    $0x1,%edi
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	eb 08                	jmp    80058b <vprintfmt+0x284>
  800583:	89 df                	mov    %ebx,%edi
  800585:	8b 75 08             	mov    0x8(%ebp),%esi
  800588:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058b:	85 ff                	test   %edi,%edi
  80058d:	7f e4                	jg     800573 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800598:	e9 90 fd ff ff       	jmp    80032d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059d:	83 f9 01             	cmp    $0x1,%ecx
  8005a0:	7e 19                	jle    8005bb <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 50 04             	mov    0x4(%eax),%edx
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 40 08             	lea    0x8(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b9:	eb 38                	jmp    8005f3 <vprintfmt+0x2ec>
	else if (lflag)
  8005bb:	85 c9                	test   %ecx,%ecx
  8005bd:	74 1b                	je     8005da <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 c1                	mov    %eax,%ecx
  8005c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d8:	eb 19                	jmp    8005f3 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	89 c1                	mov    %eax,%ecx
  8005e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800602:	0f 89 02 01 00 00    	jns    80070a <vprintfmt+0x403>
				putch('-', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 2d                	push   $0x2d
  80060e:	ff d6                	call   *%esi
				num = -(long long) num;
  800610:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800613:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800616:	f7 da                	neg    %edx
  800618:	83 d1 00             	adc    $0x0,%ecx
  80061b:	f7 d9                	neg    %ecx
  80061d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
  800625:	e9 e0 00 00 00       	jmp    80070a <vprintfmt+0x403>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062a:	83 f9 01             	cmp    $0x1,%ecx
  80062d:	7e 18                	jle    800647 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	8b 48 04             	mov    0x4(%eax),%ecx
  800637:	8d 40 08             	lea    0x8(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800642:	e9 c3 00 00 00       	jmp    80070a <vprintfmt+0x403>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800647:	85 c9                	test   %ecx,%ecx
  800649:	74 1a                	je     800665 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	b9 00 00 00 00       	mov    $0x0,%ecx
  800655:	8d 40 04             	lea    0x4(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80065b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800660:	e9 a5 00 00 00       	jmp    80070a <vprintfmt+0x403>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800675:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067a:	e9 8b 00 00 00       	jmp    80070a <vprintfmt+0x403>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('0', putdat);
			num = (unsigned long long)
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800694:	eb 74                	jmp    80070a <vprintfmt+0x403>

		// pointer
		case 'p':
			putch('0', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 30                	push   $0x30
  80069c:	ff d6                	call   *%esi
			putch('x', putdat);
  80069e:	83 c4 08             	add    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 78                	push   $0x78
  8006a4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b3:	8d 40 04             	lea    0x4(%eax),%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006be:	eb 4a                	jmp    80070a <vprintfmt+0x403>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c0:	83 f9 01             	cmp    $0x1,%ecx
  8006c3:	7e 15                	jle    8006da <vprintfmt+0x3d3>
		return va_arg(*ap, unsigned long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cd:	8d 40 08             	lea    0x8(%eax),%eax
  8006d0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d8:	eb 30                	jmp    80070a <vprintfmt+0x403>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006da:	85 c9                	test   %ecx,%ecx
  8006dc:	74 17                	je     8006f5 <vprintfmt+0x3ee>
		return va_arg(*ap, unsigned long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8b 10                	mov    (%eax),%edx
  8006e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e8:	8d 40 04             	lea    0x4(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ee:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f3:	eb 15                	jmp    80070a <vprintfmt+0x403>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 10                	mov    (%eax),%edx
  8006fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800705:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070a:	83 ec 0c             	sub    $0xc,%esp
  80070d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800711:	57                   	push   %edi
  800712:	ff 75 e0             	pushl  -0x20(%ebp)
  800715:	50                   	push   %eax
  800716:	51                   	push   %ecx
  800717:	52                   	push   %edx
  800718:	89 da                	mov    %ebx,%edx
  80071a:	89 f0                	mov    %esi,%eax
  80071c:	e8 fd fa ff ff       	call   80021e <printnum>
			break;
  800721:	83 c4 20             	add    $0x20,%esp
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 01 fc ff ff       	jmp    80032d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	52                   	push   %edx
  800731:	ff d6                	call   *%esi
			break;
  800733:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800736:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800739:	e9 ef fb ff ff       	jmp    80032d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	6a 25                	push   $0x25
  800744:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb 03                	jmp    80074e <vprintfmt+0x447>
  80074b:	83 ef 01             	sub    $0x1,%edi
  80074e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800752:	75 f7                	jne    80074b <vprintfmt+0x444>
  800754:	e9 d4 fb ff ff       	jmp    80032d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800759:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075c:	5b                   	pop    %ebx
  80075d:	5e                   	pop    %esi
  80075e:	5f                   	pop    %edi
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 18             	sub    $0x18,%esp
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800770:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800774:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800777:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077e:	85 c0                	test   %eax,%eax
  800780:	74 26                	je     8007a8 <vsnprintf+0x47>
  800782:	85 d2                	test   %edx,%edx
  800784:	7e 22                	jle    8007a8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800786:	ff 75 14             	pushl  0x14(%ebp)
  800789:	ff 75 10             	pushl  0x10(%ebp)
  80078c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	68 cd 02 80 00       	push   $0x8002cd
  800795:	e8 6d fb ff ff       	call   800307 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb 05                	jmp    8007ad <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b8:	50                   	push   %eax
  8007b9:	ff 75 10             	pushl  0x10(%ebp)
  8007bc:	ff 75 0c             	pushl  0xc(%ebp)
  8007bf:	ff 75 08             	pushl  0x8(%ebp)
  8007c2:	e8 9a ff ff ff       	call   800761 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d4:	eb 03                	jmp    8007d9 <strlen+0x10>
		n++;
  8007d6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007dd:	75 f7                	jne    8007d6 <strlen+0xd>
		n++;
	return n;
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ef:	eb 03                	jmp    8007f4 <strnlen+0x13>
		n++;
  8007f1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f4:	39 c2                	cmp    %eax,%edx
  8007f6:	74 08                	je     800800 <strnlen+0x1f>
  8007f8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007fc:	75 f3                	jne    8007f1 <strnlen+0x10>
  8007fe:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080c:	89 c2                	mov    %eax,%edx
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	83 c1 01             	add    $0x1,%ecx
  800814:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800818:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081b:	84 db                	test   %bl,%bl
  80081d:	75 ef                	jne    80080e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081f:	5b                   	pop    %ebx
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800829:	53                   	push   %ebx
  80082a:	e8 9a ff ff ff       	call   8007c9 <strlen>
  80082f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	01 d8                	add    %ebx,%eax
  800837:	50                   	push   %eax
  800838:	e8 c5 ff ff ff       	call   800802 <strcpy>
	return dst;
}
  80083d:	89 d8                	mov    %ebx,%eax
  80083f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 75 08             	mov    0x8(%ebp),%esi
  80084c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084f:	89 f3                	mov    %esi,%ebx
  800851:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800854:	89 f2                	mov    %esi,%edx
  800856:	eb 0f                	jmp    800867 <strncpy+0x23>
		*dst++ = *src;
  800858:	83 c2 01             	add    $0x1,%edx
  80085b:	0f b6 01             	movzbl (%ecx),%eax
  80085e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800861:	80 39 01             	cmpb   $0x1,(%ecx)
  800864:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800867:	39 da                	cmp    %ebx,%edx
  800869:	75 ed                	jne    800858 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80086b:	89 f0                	mov    %esi,%eax
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	56                   	push   %esi
  800875:	53                   	push   %ebx
  800876:	8b 75 08             	mov    0x8(%ebp),%esi
  800879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087c:	8b 55 10             	mov    0x10(%ebp),%edx
  80087f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800881:	85 d2                	test   %edx,%edx
  800883:	74 21                	je     8008a6 <strlcpy+0x35>
  800885:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800889:	89 f2                	mov    %esi,%edx
  80088b:	eb 09                	jmp    800896 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088d:	83 c2 01             	add    $0x1,%edx
  800890:	83 c1 01             	add    $0x1,%ecx
  800893:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800896:	39 c2                	cmp    %eax,%edx
  800898:	74 09                	je     8008a3 <strlcpy+0x32>
  80089a:	0f b6 19             	movzbl (%ecx),%ebx
  80089d:	84 db                	test   %bl,%bl
  80089f:	75 ec                	jne    80088d <strlcpy+0x1c>
  8008a1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a6:	29 f0                	sub    %esi,%eax
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b5:	eb 06                	jmp    8008bd <strcmp+0x11>
		p++, q++;
  8008b7:	83 c1 01             	add    $0x1,%ecx
  8008ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bd:	0f b6 01             	movzbl (%ecx),%eax
  8008c0:	84 c0                	test   %al,%al
  8008c2:	74 04                	je     8008c8 <strcmp+0x1c>
  8008c4:	3a 02                	cmp    (%edx),%al
  8008c6:	74 ef                	je     8008b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 c0             	movzbl %al,%eax
  8008cb:	0f b6 12             	movzbl (%edx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	89 c3                	mov    %eax,%ebx
  8008de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e1:	eb 06                	jmp    8008e9 <strncmp+0x17>
		n--, p++, q++;
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	39 d8                	cmp    %ebx,%eax
  8008eb:	74 15                	je     800902 <strncmp+0x30>
  8008ed:	0f b6 08             	movzbl (%eax),%ecx
  8008f0:	84 c9                	test   %cl,%cl
  8008f2:	74 04                	je     8008f8 <strncmp+0x26>
  8008f4:	3a 0a                	cmp    (%edx),%cl
  8008f6:	74 eb                	je     8008e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 00             	movzbl (%eax),%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
  800900:	eb 05                	jmp    800907 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800914:	eb 07                	jmp    80091d <strchr+0x13>
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 0f                	je     800929 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	0f b6 10             	movzbl (%eax),%edx
  800920:	84 d2                	test   %dl,%dl
  800922:	75 f2                	jne    800916 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800935:	eb 03                	jmp    80093a <strfind+0xf>
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093d:	38 ca                	cmp    %cl,%dl
  80093f:	74 04                	je     800945 <strfind+0x1a>
  800941:	84 d2                	test   %dl,%dl
  800943:	75 f2                	jne    800937 <strfind+0xc>
			break;
	return (char *) s;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800950:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800953:	85 c9                	test   %ecx,%ecx
  800955:	74 36                	je     80098d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800957:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095d:	75 28                	jne    800987 <memset+0x40>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	75 23                	jne    800987 <memset+0x40>
		c &= 0xFF;
  800964:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800968:	89 d3                	mov    %edx,%ebx
  80096a:	c1 e3 08             	shl    $0x8,%ebx
  80096d:	89 d6                	mov    %edx,%esi
  80096f:	c1 e6 18             	shl    $0x18,%esi
  800972:	89 d0                	mov    %edx,%eax
  800974:	c1 e0 10             	shl    $0x10,%eax
  800977:	09 f0                	or     %esi,%eax
  800979:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80097b:	89 d8                	mov    %ebx,%eax
  80097d:	09 d0                	or     %edx,%eax
  80097f:	c1 e9 02             	shr    $0x2,%ecx
  800982:	fc                   	cld    
  800983:	f3 ab                	rep stos %eax,%es:(%edi)
  800985:	eb 06                	jmp    80098d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098a:	fc                   	cld    
  80098b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a2:	39 c6                	cmp    %eax,%esi
  8009a4:	73 35                	jae    8009db <memmove+0x47>
  8009a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a9:	39 d0                	cmp    %edx,%eax
  8009ab:	73 2e                	jae    8009db <memmove+0x47>
		s += n;
		d += n;
  8009ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	89 d6                	mov    %edx,%esi
  8009b2:	09 fe                	or     %edi,%esi
  8009b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ba:	75 13                	jne    8009cf <memmove+0x3b>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 0e                	jne    8009cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c1:	83 ef 04             	sub    $0x4,%edi
  8009c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
  8009ca:	fd                   	std    
  8009cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cd:	eb 09                	jmp    8009d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cf:	83 ef 01             	sub    $0x1,%edi
  8009d2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d5:	fd                   	std    
  8009d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d8:	fc                   	cld    
  8009d9:	eb 1d                	jmp    8009f8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009db:	89 f2                	mov    %esi,%edx
  8009dd:	09 c2                	or     %eax,%edx
  8009df:	f6 c2 03             	test   $0x3,%dl
  8009e2:	75 0f                	jne    8009f3 <memmove+0x5f>
  8009e4:	f6 c1 03             	test   $0x3,%cl
  8009e7:	75 0a                	jne    8009f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
  8009ec:	89 c7                	mov    %eax,%edi
  8009ee:	fc                   	cld    
  8009ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f1:	eb 05                	jmp    8009f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f3:	89 c7                	mov    %eax,%edi
  8009f5:	fc                   	cld    
  8009f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f8:	5e                   	pop    %esi
  8009f9:	5f                   	pop    %edi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ff:	ff 75 10             	pushl  0x10(%ebp)
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	ff 75 08             	pushl  0x8(%ebp)
  800a08:	e8 87 ff ff ff       	call   800994 <memmove>
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	89 c6                	mov    %eax,%esi
  800a1c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	eb 1a                	jmp    800a3b <memcmp+0x2c>
		if (*s1 != *s2)
  800a21:	0f b6 08             	movzbl (%eax),%ecx
  800a24:	0f b6 1a             	movzbl (%edx),%ebx
  800a27:	38 d9                	cmp    %bl,%cl
  800a29:	74 0a                	je     800a35 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a2b:	0f b6 c1             	movzbl %cl,%eax
  800a2e:	0f b6 db             	movzbl %bl,%ebx
  800a31:	29 d8                	sub    %ebx,%eax
  800a33:	eb 0f                	jmp    800a44 <memcmp+0x35>
		s1++, s2++;
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3b:	39 f0                	cmp    %esi,%eax
  800a3d:	75 e2                	jne    800a21 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	53                   	push   %ebx
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4f:	89 c1                	mov    %eax,%ecx
  800a51:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a54:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a58:	eb 0a                	jmp    800a64 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5a:	0f b6 10             	movzbl (%eax),%edx
  800a5d:	39 da                	cmp    %ebx,%edx
  800a5f:	74 07                	je     800a68 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	39 c8                	cmp    %ecx,%eax
  800a66:	72 f2                	jb     800a5a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a68:	5b                   	pop    %ebx
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	eb 03                	jmp    800a7c <strtol+0x11>
		s++;
  800a79:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	0f b6 01             	movzbl (%ecx),%eax
  800a7f:	3c 20                	cmp    $0x20,%al
  800a81:	74 f6                	je     800a79 <strtol+0xe>
  800a83:	3c 09                	cmp    $0x9,%al
  800a85:	74 f2                	je     800a79 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a87:	3c 2b                	cmp    $0x2b,%al
  800a89:	75 0a                	jne    800a95 <strtol+0x2a>
		s++;
  800a8b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a93:	eb 11                	jmp    800aa6 <strtol+0x3b>
  800a95:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9a:	3c 2d                	cmp    $0x2d,%al
  800a9c:	75 08                	jne    800aa6 <strtol+0x3b>
		s++, neg = 1;
  800a9e:	83 c1 01             	add    $0x1,%ecx
  800aa1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aac:	75 15                	jne    800ac3 <strtol+0x58>
  800aae:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab1:	75 10                	jne    800ac3 <strtol+0x58>
  800ab3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab7:	75 7c                	jne    800b35 <strtol+0xca>
		s += 2, base = 16;
  800ab9:	83 c1 02             	add    $0x2,%ecx
  800abc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac1:	eb 16                	jmp    800ad9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	75 12                	jne    800ad9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acc:	80 39 30             	cmpb   $0x30,(%ecx)
  800acf:	75 08                	jne    800ad9 <strtol+0x6e>
		s++, base = 8;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae1:	0f b6 11             	movzbl (%ecx),%edx
  800ae4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 09             	cmp    $0x9,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x8b>
			dig = *s - '0';
  800aee:	0f be d2             	movsbl %dl,%edx
  800af1:	83 ea 30             	sub    $0x30,%edx
  800af4:	eb 22                	jmp    800b18 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 08                	ja     800b08 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	83 ea 57             	sub    $0x57,%edx
  800b06:	eb 10                	jmp    800b18 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b08:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0b:	89 f3                	mov    %esi,%ebx
  800b0d:	80 fb 19             	cmp    $0x19,%bl
  800b10:	77 16                	ja     800b28 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b12:	0f be d2             	movsbl %dl,%edx
  800b15:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b18:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b1b:	7d 0b                	jge    800b28 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b1d:	83 c1 01             	add    $0x1,%ecx
  800b20:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b24:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b26:	eb b9                	jmp    800ae1 <strtol+0x76>

	if (endptr)
  800b28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2c:	74 0d                	je     800b3b <strtol+0xd0>
		*endptr = (char *) s;
  800b2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b31:	89 0e                	mov    %ecx,(%esi)
  800b33:	eb 06                	jmp    800b3b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b35:	85 db                	test   %ebx,%ebx
  800b37:	74 98                	je     800ad1 <strtol+0x66>
  800b39:	eb 9e                	jmp    800ad9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	f7 da                	neg    %edx
  800b3f:	85 ff                	test   %edi,%edi
  800b41:	0f 45 c2             	cmovne %edx,%eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    
  800b49:	66 90                	xchg   %ax,%ax
  800b4b:	66 90                	xchg   %ax,%ax
  800b4d:	66 90                	xchg   %ax,%ax
  800b4f:	90                   	nop

00800b50 <__udivdi3>:
  800b50:	55                   	push   %ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 1c             	sub    $0x1c,%esp
  800b57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b67:	85 f6                	test   %esi,%esi
  800b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b6d:	89 ca                	mov    %ecx,%edx
  800b6f:	89 f8                	mov    %edi,%eax
  800b71:	75 3d                	jne    800bb0 <__udivdi3+0x60>
  800b73:	39 cf                	cmp    %ecx,%edi
  800b75:	0f 87 c5 00 00 00    	ja     800c40 <__udivdi3+0xf0>
  800b7b:	85 ff                	test   %edi,%edi
  800b7d:	89 fd                	mov    %edi,%ebp
  800b7f:	75 0b                	jne    800b8c <__udivdi3+0x3c>
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	31 d2                	xor    %edx,%edx
  800b88:	f7 f7                	div    %edi
  800b8a:	89 c5                	mov    %eax,%ebp
  800b8c:	89 c8                	mov    %ecx,%eax
  800b8e:	31 d2                	xor    %edx,%edx
  800b90:	f7 f5                	div    %ebp
  800b92:	89 c1                	mov    %eax,%ecx
  800b94:	89 d8                	mov    %ebx,%eax
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	f7 f5                	div    %ebp
  800b9a:	89 c3                	mov    %eax,%ebx
  800b9c:	89 d8                	mov    %ebx,%eax
  800b9e:	89 fa                	mov    %edi,%edx
  800ba0:	83 c4 1c             	add    $0x1c,%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
  800ba8:	90                   	nop
  800ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bb0:	39 ce                	cmp    %ecx,%esi
  800bb2:	77 74                	ja     800c28 <__udivdi3+0xd8>
  800bb4:	0f bd fe             	bsr    %esi,%edi
  800bb7:	83 f7 1f             	xor    $0x1f,%edi
  800bba:	0f 84 98 00 00 00    	je     800c58 <__udivdi3+0x108>
  800bc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bc5:	89 f9                	mov    %edi,%ecx
  800bc7:	89 c5                	mov    %eax,%ebp
  800bc9:	29 fb                	sub    %edi,%ebx
  800bcb:	d3 e6                	shl    %cl,%esi
  800bcd:	89 d9                	mov    %ebx,%ecx
  800bcf:	d3 ed                	shr    %cl,%ebp
  800bd1:	89 f9                	mov    %edi,%ecx
  800bd3:	d3 e0                	shl    %cl,%eax
  800bd5:	09 ee                	or     %ebp,%esi
  800bd7:	89 d9                	mov    %ebx,%ecx
  800bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bdd:	89 d5                	mov    %edx,%ebp
  800bdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800be3:	d3 ed                	shr    %cl,%ebp
  800be5:	89 f9                	mov    %edi,%ecx
  800be7:	d3 e2                	shl    %cl,%edx
  800be9:	89 d9                	mov    %ebx,%ecx
  800beb:	d3 e8                	shr    %cl,%eax
  800bed:	09 c2                	or     %eax,%edx
  800bef:	89 d0                	mov    %edx,%eax
  800bf1:	89 ea                	mov    %ebp,%edx
  800bf3:	f7 f6                	div    %esi
  800bf5:	89 d5                	mov    %edx,%ebp
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	f7 64 24 0c          	mull   0xc(%esp)
  800bfd:	39 d5                	cmp    %edx,%ebp
  800bff:	72 10                	jb     800c11 <__udivdi3+0xc1>
  800c01:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c05:	89 f9                	mov    %edi,%ecx
  800c07:	d3 e6                	shl    %cl,%esi
  800c09:	39 c6                	cmp    %eax,%esi
  800c0b:	73 07                	jae    800c14 <__udivdi3+0xc4>
  800c0d:	39 d5                	cmp    %edx,%ebp
  800c0f:	75 03                	jne    800c14 <__udivdi3+0xc4>
  800c11:	83 eb 01             	sub    $0x1,%ebx
  800c14:	31 ff                	xor    %edi,%edi
  800c16:	89 d8                	mov    %ebx,%eax
  800c18:	89 fa                	mov    %edi,%edx
  800c1a:	83 c4 1c             	add    $0x1c,%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    
  800c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c28:	31 ff                	xor    %edi,%edi
  800c2a:	31 db                	xor    %ebx,%ebx
  800c2c:	89 d8                	mov    %ebx,%eax
  800c2e:	89 fa                	mov    %edi,%edx
  800c30:	83 c4 1c             	add    $0x1c,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    
  800c38:	90                   	nop
  800c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c40:	89 d8                	mov    %ebx,%eax
  800c42:	f7 f7                	div    %edi
  800c44:	31 ff                	xor    %edi,%edi
  800c46:	89 c3                	mov    %eax,%ebx
  800c48:	89 d8                	mov    %ebx,%eax
  800c4a:	89 fa                	mov    %edi,%edx
  800c4c:	83 c4 1c             	add    $0x1c,%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    
  800c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c58:	39 ce                	cmp    %ecx,%esi
  800c5a:	72 0c                	jb     800c68 <__udivdi3+0x118>
  800c5c:	31 db                	xor    %ebx,%ebx
  800c5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c62:	0f 87 34 ff ff ff    	ja     800b9c <__udivdi3+0x4c>
  800c68:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c6d:	e9 2a ff ff ff       	jmp    800b9c <__udivdi3+0x4c>
  800c72:	66 90                	xchg   %ax,%ax
  800c74:	66 90                	xchg   %ax,%ax
  800c76:	66 90                	xchg   %ax,%ax
  800c78:	66 90                	xchg   %ax,%ax
  800c7a:	66 90                	xchg   %ax,%ax
  800c7c:	66 90                	xchg   %ax,%ax
  800c7e:	66 90                	xchg   %ax,%ax

00800c80 <__umoddi3>:
  800c80:	55                   	push   %ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 1c             	sub    $0x1c,%esp
  800c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c97:	85 d2                	test   %edx,%edx
  800c99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	89 3c 24             	mov    %edi,(%esp)
  800ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800caa:	75 1c                	jne    800cc8 <__umoddi3+0x48>
  800cac:	39 f7                	cmp    %esi,%edi
  800cae:	76 50                	jbe    800d00 <__umoddi3+0x80>
  800cb0:	89 c8                	mov    %ecx,%eax
  800cb2:	89 f2                	mov    %esi,%edx
  800cb4:	f7 f7                	div    %edi
  800cb6:	89 d0                	mov    %edx,%eax
  800cb8:	31 d2                	xor    %edx,%edx
  800cba:	83 c4 1c             	add    $0x1c,%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    
  800cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cc8:	39 f2                	cmp    %esi,%edx
  800cca:	89 d0                	mov    %edx,%eax
  800ccc:	77 52                	ja     800d20 <__umoddi3+0xa0>
  800cce:	0f bd ea             	bsr    %edx,%ebp
  800cd1:	83 f5 1f             	xor    $0x1f,%ebp
  800cd4:	75 5a                	jne    800d30 <__umoddi3+0xb0>
  800cd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cda:	0f 82 e0 00 00 00    	jb     800dc0 <__umoddi3+0x140>
  800ce0:	39 0c 24             	cmp    %ecx,(%esp)
  800ce3:	0f 86 d7 00 00 00    	jbe    800dc0 <__umoddi3+0x140>
  800ce9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ced:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cf1:	83 c4 1c             	add    $0x1c,%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
  800cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d00:	85 ff                	test   %edi,%edi
  800d02:	89 fd                	mov    %edi,%ebp
  800d04:	75 0b                	jne    800d11 <__umoddi3+0x91>
  800d06:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0b:	31 d2                	xor    %edx,%edx
  800d0d:	f7 f7                	div    %edi
  800d0f:	89 c5                	mov    %eax,%ebp
  800d11:	89 f0                	mov    %esi,%eax
  800d13:	31 d2                	xor    %edx,%edx
  800d15:	f7 f5                	div    %ebp
  800d17:	89 c8                	mov    %ecx,%eax
  800d19:	f7 f5                	div    %ebp
  800d1b:	89 d0                	mov    %edx,%eax
  800d1d:	eb 99                	jmp    800cb8 <__umoddi3+0x38>
  800d1f:	90                   	nop
  800d20:	89 c8                	mov    %ecx,%eax
  800d22:	89 f2                	mov    %esi,%edx
  800d24:	83 c4 1c             	add    $0x1c,%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    
  800d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d30:	8b 34 24             	mov    (%esp),%esi
  800d33:	bf 20 00 00 00       	mov    $0x20,%edi
  800d38:	89 e9                	mov    %ebp,%ecx
  800d3a:	29 ef                	sub    %ebp,%edi
  800d3c:	d3 e0                	shl    %cl,%eax
  800d3e:	89 f9                	mov    %edi,%ecx
  800d40:	89 f2                	mov    %esi,%edx
  800d42:	d3 ea                	shr    %cl,%edx
  800d44:	89 e9                	mov    %ebp,%ecx
  800d46:	09 c2                	or     %eax,%edx
  800d48:	89 d8                	mov    %ebx,%eax
  800d4a:	89 14 24             	mov    %edx,(%esp)
  800d4d:	89 f2                	mov    %esi,%edx
  800d4f:	d3 e2                	shl    %cl,%edx
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d5b:	d3 e8                	shr    %cl,%eax
  800d5d:	89 e9                	mov    %ebp,%ecx
  800d5f:	89 c6                	mov    %eax,%esi
  800d61:	d3 e3                	shl    %cl,%ebx
  800d63:	89 f9                	mov    %edi,%ecx
  800d65:	89 d0                	mov    %edx,%eax
  800d67:	d3 e8                	shr    %cl,%eax
  800d69:	89 e9                	mov    %ebp,%ecx
  800d6b:	09 d8                	or     %ebx,%eax
  800d6d:	89 d3                	mov    %edx,%ebx
  800d6f:	89 f2                	mov    %esi,%edx
  800d71:	f7 34 24             	divl   (%esp)
  800d74:	89 d6                	mov    %edx,%esi
  800d76:	d3 e3                	shl    %cl,%ebx
  800d78:	f7 64 24 04          	mull   0x4(%esp)
  800d7c:	39 d6                	cmp    %edx,%esi
  800d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 c3                	mov    %eax,%ebx
  800d86:	72 08                	jb     800d90 <__umoddi3+0x110>
  800d88:	75 11                	jne    800d9b <__umoddi3+0x11b>
  800d8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d8e:	73 0b                	jae    800d9b <__umoddi3+0x11b>
  800d90:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d94:	1b 14 24             	sbb    (%esp),%edx
  800d97:	89 d1                	mov    %edx,%ecx
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d9f:	29 da                	sub    %ebx,%edx
  800da1:	19 ce                	sbb    %ecx,%esi
  800da3:	89 f9                	mov    %edi,%ecx
  800da5:	89 f0                	mov    %esi,%eax
  800da7:	d3 e0                	shl    %cl,%eax
  800da9:	89 e9                	mov    %ebp,%ecx
  800dab:	d3 ea                	shr    %cl,%edx
  800dad:	89 e9                	mov    %ebp,%ecx
  800daf:	d3 ee                	shr    %cl,%esi
  800db1:	09 d0                	or     %edx,%eax
  800db3:	89 f2                	mov    %esi,%edx
  800db5:	83 c4 1c             	add    $0x1c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi
  800dc0:	29 f9                	sub    %edi,%ecx
  800dc2:	19 d6                	sbb    %edx,%esi
  800dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dcc:	e9 18 ff ff ff       	jmp    800ce9 <__umoddi3+0x69>
