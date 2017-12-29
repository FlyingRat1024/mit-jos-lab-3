
obj/user/softint：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 c9 00 00 00       	call   800113 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800052:	c1 e0 05             	shl    $0x5,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800089:	6a 00                	push   $0x0
  80008b:	e8 42 00 00 00       	call   8000d2 <sys_env_destroy>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5f                   	pop    %edi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000be:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c3:	89 d1                	mov    %edx,%ecx
  8000c5:	89 d3                	mov    %edx,%ebx
  8000c7:	89 d7                	mov    %edx,%edi
  8000c9:	89 d6                	mov    %edx,%esi
  8000cb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	89 cb                	mov    %ecx,%ebx
  8000ea:	89 cf                	mov    %ecx,%edi
  8000ec:	89 ce                	mov    %ecx,%esi
  8000ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	7e 17                	jle    80010b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	6a 03                	push   $0x3
  8000fa:	68 ea 0d 80 00       	push   $0x800dea
  8000ff:	6a 23                	push   $0x23
  800101:	68 07 0e 80 00       	push   $0x800e07
  800106:	e8 27 00 00 00       	call   800132 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800119:	ba 00 00 00 00       	mov    $0x0,%edx
  80011e:	b8 02 00 00 00       	mov    $0x2,%eax
  800123:	89 d1                	mov    %edx,%ecx
  800125:	89 d3                	mov    %edx,%ebx
  800127:	89 d7                	mov    %edx,%edi
  800129:	89 d6                	mov    %edx,%esi
  80012b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800137:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800140:	e8 ce ff ff ff       	call   800113 <sys_getenvid>
  800145:	83 ec 0c             	sub    $0xc,%esp
  800148:	ff 75 0c             	pushl  0xc(%ebp)
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	56                   	push   %esi
  80014f:	50                   	push   %eax
  800150:	68 18 0e 80 00       	push   $0x800e18
  800155:	e8 b1 00 00 00       	call   80020b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015a:	83 c4 18             	add    $0x18,%esp
  80015d:	53                   	push   %ebx
  80015e:	ff 75 10             	pushl  0x10(%ebp)
  800161:	e8 54 00 00 00       	call   8001ba <vcprintf>
	cprintf("\n");
  800166:	c7 04 24 3c 0e 80 00 	movl   $0x800e3c,(%esp)
  80016d:	e8 99 00 00 00       	call   80020b <cprintf>
  800172:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800175:	cc                   	int3   
  800176:	eb fd                	jmp    800175 <_panic+0x43>

00800178 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	53                   	push   %ebx
  80017c:	83 ec 04             	sub    $0x4,%esp
  80017f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800182:	8b 13                	mov    (%ebx),%edx
  800184:	8d 42 01             	lea    0x1(%edx),%eax
  800187:	89 03                	mov    %eax,(%ebx)
  800189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800190:	3d ff 00 00 00       	cmp    $0xff,%eax
  800195:	75 1a                	jne    8001b1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800197:	83 ec 08             	sub    $0x8,%esp
  80019a:	68 ff 00 00 00       	push   $0xff
  80019f:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a2:	50                   	push   %eax
  8001a3:	e8 ed fe ff ff       	call   800095 <sys_cputs>
		b->idx = 0;
  8001a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ae:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ca:	00 00 00 
	b.cnt = 0;
  8001cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d7:	ff 75 0c             	pushl  0xc(%ebp)
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	68 78 01 80 00       	push   $0x800178
  8001e9:	e8 1a 01 00 00       	call   800308 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ee:	83 c4 08             	add    $0x8,%esp
  8001f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fd:	50                   	push   %eax
  8001fe:	e8 92 fe ff ff       	call   800095 <sys_cputs>

	return b.cnt;
}
  800203:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800211:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800214:	50                   	push   %eax
  800215:	ff 75 08             	pushl  0x8(%ebp)
  800218:	e8 9d ff ff ff       	call   8001ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 1c             	sub    $0x1c,%esp
  800228:	89 c7                	mov    %eax,%edi
  80022a:	89 d6                	mov    %edx,%esi
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800232:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800235:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800240:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800243:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800246:	39 d3                	cmp    %edx,%ebx
  800248:	72 05                	jb     80024f <printnum+0x30>
  80024a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024d:	77 45                	ja     800294 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	ff 75 18             	pushl  0x18(%ebp)
  800255:	8b 45 14             	mov    0x14(%ebp),%eax
  800258:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025b:	53                   	push   %ebx
  80025c:	ff 75 10             	pushl  0x10(%ebp)
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	ff 75 e4             	pushl  -0x1c(%ebp)
  800265:	ff 75 e0             	pushl  -0x20(%ebp)
  800268:	ff 75 dc             	pushl  -0x24(%ebp)
  80026b:	ff 75 d8             	pushl  -0x28(%ebp)
  80026e:	e8 dd 08 00 00       	call   800b50 <__udivdi3>
  800273:	83 c4 18             	add    $0x18,%esp
  800276:	52                   	push   %edx
  800277:	50                   	push   %eax
  800278:	89 f2                	mov    %esi,%edx
  80027a:	89 f8                	mov    %edi,%eax
  80027c:	e8 9e ff ff ff       	call   80021f <printnum>
  800281:	83 c4 20             	add    $0x20,%esp
  800284:	eb 18                	jmp    80029e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	ff 75 18             	pushl  0x18(%ebp)
  80028d:	ff d7                	call   *%edi
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	eb 03                	jmp    800297 <printnum+0x78>
  800294:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800297:	83 eb 01             	sub    $0x1,%ebx
  80029a:	85 db                	test   %ebx,%ebx
  80029c:	7f e8                	jg     800286 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	83 ec 04             	sub    $0x4,%esp
  8002a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b1:	e8 ca 09 00 00       	call   800c80 <__umoddi3>
  8002b6:	83 c4 14             	add    $0x14,%esp
  8002b9:	0f be 80 3e 0e 80 00 	movsbl 0x800e3e(%eax),%eax
  8002c0:	50                   	push   %eax
  8002c1:	ff d7                	call   *%edi
}
  8002c3:	83 c4 10             	add    $0x10,%esp
  8002c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dd:	73 0a                	jae    8002e9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002df:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e7:	88 02                	mov    %al,(%edx)
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f4:	50                   	push   %eax
  8002f5:	ff 75 10             	pushl  0x10(%ebp)
  8002f8:	ff 75 0c             	pushl  0xc(%ebp)
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 05 00 00 00       	call   800308 <vprintfmt>
	va_end(ap);
}
  800303:	83 c4 10             	add    $0x10,%esp
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	57                   	push   %edi
  80030c:	56                   	push   %esi
  80030d:	53                   	push   %ebx
  80030e:	83 ec 2c             	sub    $0x2c,%esp
  800311:	8b 75 08             	mov    0x8(%ebp),%esi
  800314:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800317:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031a:	eb 12                	jmp    80032e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031c:	85 c0                	test   %eax,%eax
  80031e:	0f 84 36 04 00 00    	je     80075a <vprintfmt+0x452>
				return;
			putch(ch, putdat);
  800324:	83 ec 08             	sub    $0x8,%esp
  800327:	53                   	push   %ebx
  800328:	50                   	push   %eax
  800329:	ff d6                	call   *%esi
  80032b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032e:	83 c7 01             	add    $0x1,%edi
  800331:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800335:	83 f8 25             	cmp    $0x25,%eax
  800338:	75 e2                	jne    80031c <vprintfmt+0x14>
  80033a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80033e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800345:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800353:	b9 00 00 00 00       	mov    $0x0,%ecx
  800358:	eb 07                	jmp    800361 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8d 47 01             	lea    0x1(%edi),%eax
  800364:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800367:	0f b6 07             	movzbl (%edi),%eax
  80036a:	0f b6 d0             	movzbl %al,%edx
  80036d:	83 e8 23             	sub    $0x23,%eax
  800370:	3c 55                	cmp    $0x55,%al
  800372:	0f 87 c7 03 00 00    	ja     80073f <vprintfmt+0x437>
  800378:	0f b6 c0             	movzbl %al,%eax
  80037b:	ff 24 85 e0 0e 80 00 	jmp    *0x800ee0(,%eax,4)
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800385:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800389:	eb d6                	jmp    800361 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038e:	b8 00 00 00 00       	mov    $0x0,%eax
  800393:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800396:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800399:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a3:	83 f9 09             	cmp    $0x9,%ecx
  8003a6:	77 3f                	ja     8003e7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ab:	eb e9                	jmp    800396 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 40 04             	lea    0x4(%eax),%eax
  8003bb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c1:	eb 2a                	jmp    8003ed <vprintfmt+0xe5>
  8003c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	0f 49 d0             	cmovns %eax,%edx
  8003d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d6:	eb 89                	jmp    800361 <vprintfmt+0x59>
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e2:	e9 7a ff ff ff       	jmp    800361 <vprintfmt+0x59>
  8003e7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f1:	0f 89 6a ff ff ff    	jns    800361 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800404:	e9 58 ff ff ff       	jmp    800361 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800409:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040f:	e9 4d ff ff ff       	jmp    800361 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 78 04             	lea    0x4(%eax),%edi
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 30                	pushl  (%eax)
  800420:	ff d6                	call   *%esi
			break;
  800422:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800425:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042b:	e9 fe fe ff ff       	jmp    80032e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 78 04             	lea    0x4(%eax),%edi
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 07             	cmp    $0x7,%eax
  800440:	7f 0b                	jg     80044d <vprintfmt+0x145>
  800442:	8b 14 85 40 10 80 00 	mov    0x801040(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 1b                	jne    800468 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 56 0e 80 00       	push   $0x800e56
  800453:	53                   	push   %ebx
  800454:	56                   	push   %esi
  800455:	e8 91 fe ff ff       	call   8002eb <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 c6 fe ff ff       	jmp    80032e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	52                   	push   %edx
  800469:	68 5f 0e 80 00       	push   $0x800e5f
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 76 fe ff ff       	call   8002eb <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047e:	e9 ab fe ff ff       	jmp    80032e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	83 c0 04             	add    $0x4,%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800491:	85 ff                	test   %edi,%edi
  800493:	b8 4f 0e 80 00       	mov    $0x800e4f,%eax
  800498:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049f:	0f 8e 94 00 00 00    	jle    800539 <vprintfmt+0x231>
  8004a5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a9:	0f 84 98 00 00 00    	je     800547 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b5:	57                   	push   %edi
  8004b6:	e8 27 03 00 00       	call   8007e2 <strnlen>
  8004bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004be:	29 c1                	sub    %eax,%ecx
  8004c0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004c3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	eb 0f                	jmp    8004e3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	53                   	push   %ebx
  8004d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004db:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dd:	83 ef 01             	sub    $0x1,%edi
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	85 ff                	test   %edi,%edi
  8004e5:	7f ed                	jg     8004d4 <vprintfmt+0x1cc>
  8004e7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ea:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f4:	0f 49 c1             	cmovns %ecx,%eax
  8004f7:	29 c1                	sub    %eax,%ecx
  8004f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800502:	89 cb                	mov    %ecx,%ebx
  800504:	eb 4d                	jmp    800553 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800506:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050a:	74 1b                	je     800527 <vprintfmt+0x21f>
  80050c:	0f be c0             	movsbl %al,%eax
  80050f:	83 e8 20             	sub    $0x20,%eax
  800512:	83 f8 5e             	cmp    $0x5e,%eax
  800515:	76 10                	jbe    800527 <vprintfmt+0x21f>
					putch('?', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	ff 75 0c             	pushl  0xc(%ebp)
  80051d:	6a 3f                	push   $0x3f
  80051f:	ff 55 08             	call   *0x8(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	eb 0d                	jmp    800534 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	52                   	push   %edx
  80052e:	ff 55 08             	call   *0x8(%ebp)
  800531:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800534:	83 eb 01             	sub    $0x1,%ebx
  800537:	eb 1a                	jmp    800553 <vprintfmt+0x24b>
  800539:	89 75 08             	mov    %esi,0x8(%ebp)
  80053c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800542:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800545:	eb 0c                	jmp    800553 <vprintfmt+0x24b>
  800547:	89 75 08             	mov    %esi,0x8(%ebp)
  80054a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800550:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800553:	83 c7 01             	add    $0x1,%edi
  800556:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055a:	0f be d0             	movsbl %al,%edx
  80055d:	85 d2                	test   %edx,%edx
  80055f:	74 23                	je     800584 <vprintfmt+0x27c>
  800561:	85 f6                	test   %esi,%esi
  800563:	78 a1                	js     800506 <vprintfmt+0x1fe>
  800565:	83 ee 01             	sub    $0x1,%esi
  800568:	79 9c                	jns    800506 <vprintfmt+0x1fe>
  80056a:	89 df                	mov    %ebx,%edi
  80056c:	8b 75 08             	mov    0x8(%ebp),%esi
  80056f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800572:	eb 18                	jmp    80058c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	53                   	push   %ebx
  800578:	6a 20                	push   $0x20
  80057a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057c:	83 ef 01             	sub    $0x1,%edi
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	eb 08                	jmp    80058c <vprintfmt+0x284>
  800584:	89 df                	mov    %ebx,%edi
  800586:	8b 75 08             	mov    0x8(%ebp),%esi
  800589:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058c:	85 ff                	test   %edi,%edi
  80058e:	7f e4                	jg     800574 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800590:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800599:	e9 90 fd ff ff       	jmp    80032e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059e:	83 f9 01             	cmp    $0x1,%ecx
  8005a1:	7e 19                	jle    8005bc <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 50 04             	mov    0x4(%eax),%edx
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 40 08             	lea    0x8(%eax),%eax
  8005b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ba:	eb 38                	jmp    8005f4 <vprintfmt+0x2ec>
	else if (lflag)
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	74 1b                	je     8005db <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	89 c1                	mov    %eax,%ecx
  8005ca:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d9:	eb 19                	jmp    8005f4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800603:	0f 89 02 01 00 00    	jns    80070b <vprintfmt+0x403>
				putch('-', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 2d                	push   $0x2d
  80060f:	ff d6                	call   *%esi
				num = -(long long) num;
  800611:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800614:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800617:	f7 da                	neg    %edx
  800619:	83 d1 00             	adc    $0x0,%ecx
  80061c:	f7 d9                	neg    %ecx
  80061e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
  800626:	e9 e0 00 00 00       	jmp    80070b <vprintfmt+0x403>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062b:	83 f9 01             	cmp    $0x1,%ecx
  80062e:	7e 18                	jle    800648 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	8b 48 04             	mov    0x4(%eax),%ecx
  800638:	8d 40 08             	lea    0x8(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 c3 00 00 00       	jmp    80070b <vprintfmt+0x403>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800648:	85 c9                	test   %ecx,%ecx
  80064a:	74 1a                	je     800666 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 a5 00 00 00       	jmp    80070b <vprintfmt+0x403>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800676:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067b:	e9 8b 00 00 00       	jmp    80070b <vprintfmt+0x403>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('0', putdat);
			num = (unsigned long long)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 10                	mov    (%eax),%edx
  800685:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  80068a:	8d 40 04             	lea    0x4(%eax),%eax
  80068d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800690:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800695:	eb 74                	jmp    80070b <vprintfmt+0x403>

		// pointer
		case 'p':
			putch('0', putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 30                	push   $0x30
  80069d:	ff d6                	call   *%esi
			putch('x', putdat);
  80069f:	83 c4 08             	add    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 78                	push   $0x78
  8006a5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b1:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bf:	eb 4a                	jmp    80070b <vprintfmt+0x403>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c1:	83 f9 01             	cmp    $0x1,%ecx
  8006c4:	7e 15                	jle    8006db <vprintfmt+0x3d3>
		return va_arg(*ap, unsigned long long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 10                	mov    (%eax),%edx
  8006cb:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ce:	8d 40 08             	lea    0x8(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d9:	eb 30                	jmp    80070b <vprintfmt+0x403>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006db:	85 c9                	test   %ecx,%ecx
  8006dd:	74 17                	je     8006f6 <vprintfmt+0x3ee>
		return va_arg(*ap, unsigned long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 10                	mov    (%eax),%edx
  8006e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ec:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f4:	eb 15                	jmp    80070b <vprintfmt+0x403>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800706:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070b:	83 ec 0c             	sub    $0xc,%esp
  80070e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800712:	57                   	push   %edi
  800713:	ff 75 e0             	pushl  -0x20(%ebp)
  800716:	50                   	push   %eax
  800717:	51                   	push   %ecx
  800718:	52                   	push   %edx
  800719:	89 da                	mov    %ebx,%edx
  80071b:	89 f0                	mov    %esi,%eax
  80071d:	e8 fd fa ff ff       	call   80021f <printnum>
			break;
  800722:	83 c4 20             	add    $0x20,%esp
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800728:	e9 01 fc ff ff       	jmp    80032e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	52                   	push   %edx
  800732:	ff d6                	call   *%esi
			break;
  800734:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073a:	e9 ef fb ff ff       	jmp    80032e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	6a 25                	push   $0x25
  800745:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 03                	jmp    80074f <vprintfmt+0x447>
  80074c:	83 ef 01             	sub    $0x1,%edi
  80074f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800753:	75 f7                	jne    80074c <vprintfmt+0x444>
  800755:	e9 d4 fb ff ff       	jmp    80032e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80075a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075d:	5b                   	pop    %ebx
  80075e:	5e                   	pop    %esi
  80075f:	5f                   	pop    %edi
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 18             	sub    $0x18,%esp
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800771:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800775:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077f:	85 c0                	test   %eax,%eax
  800781:	74 26                	je     8007a9 <vsnprintf+0x47>
  800783:	85 d2                	test   %edx,%edx
  800785:	7e 22                	jle    8007a9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800787:	ff 75 14             	pushl  0x14(%ebp)
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800790:	50                   	push   %eax
  800791:	68 ce 02 80 00       	push   $0x8002ce
  800796:	e8 6d fb ff ff       	call   800308 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	eb 05                	jmp    8007ae <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 9a ff ff ff       	call   800762 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d5:	eb 03                	jmp    8007da <strlen+0x10>
		n++;
  8007d7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007de:	75 f7                	jne    8007d7 <strlen+0xd>
		n++;
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f0:	eb 03                	jmp    8007f5 <strnlen+0x13>
		n++;
  8007f2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f5:	39 c2                	cmp    %eax,%edx
  8007f7:	74 08                	je     800801 <strnlen+0x1f>
  8007f9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007fd:	75 f3                	jne    8007f2 <strnlen+0x10>
  8007ff:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080d:	89 c2                	mov    %eax,%edx
  80080f:	83 c2 01             	add    $0x1,%edx
  800812:	83 c1 01             	add    $0x1,%ecx
  800815:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800819:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081c:	84 db                	test   %bl,%bl
  80081e:	75 ef                	jne    80080f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800820:	5b                   	pop    %ebx
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082a:	53                   	push   %ebx
  80082b:	e8 9a ff ff ff       	call   8007ca <strlen>
  800830:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800833:	ff 75 0c             	pushl  0xc(%ebp)
  800836:	01 d8                	add    %ebx,%eax
  800838:	50                   	push   %eax
  800839:	e8 c5 ff ff ff       	call   800803 <strcpy>
	return dst;
}
  80083e:	89 d8                	mov    %ebx,%eax
  800840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	8b 75 08             	mov    0x8(%ebp),%esi
  80084d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800850:	89 f3                	mov    %esi,%ebx
  800852:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800855:	89 f2                	mov    %esi,%edx
  800857:	eb 0f                	jmp    800868 <strncpy+0x23>
		*dst++ = *src;
  800859:	83 c2 01             	add    $0x1,%edx
  80085c:	0f b6 01             	movzbl (%ecx),%eax
  80085f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800862:	80 39 01             	cmpb   $0x1,(%ecx)
  800865:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800868:	39 da                	cmp    %ebx,%edx
  80086a:	75 ed                	jne    800859 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80086c:	89 f0                	mov    %esi,%eax
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 75 08             	mov    0x8(%ebp),%esi
  80087a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087d:	8b 55 10             	mov    0x10(%ebp),%edx
  800880:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800882:	85 d2                	test   %edx,%edx
  800884:	74 21                	je     8008a7 <strlcpy+0x35>
  800886:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088a:	89 f2                	mov    %esi,%edx
  80088c:	eb 09                	jmp    800897 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088e:	83 c2 01             	add    $0x1,%edx
  800891:	83 c1 01             	add    $0x1,%ecx
  800894:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800897:	39 c2                	cmp    %eax,%edx
  800899:	74 09                	je     8008a4 <strlcpy+0x32>
  80089b:	0f b6 19             	movzbl (%ecx),%ebx
  80089e:	84 db                	test   %bl,%bl
  8008a0:	75 ec                	jne    80088e <strlcpy+0x1c>
  8008a2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a7:	29 f0                	sub    %esi,%eax
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5e                   	pop    %esi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b6:	eb 06                	jmp    8008be <strcmp+0x11>
		p++, q++;
  8008b8:	83 c1 01             	add    $0x1,%ecx
  8008bb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008be:	0f b6 01             	movzbl (%ecx),%eax
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 04                	je     8008c9 <strcmp+0x1c>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	74 ef                	je     8008b8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 c0             	movzbl %al,%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dd:	89 c3                	mov    %eax,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e2:	eb 06                	jmp    8008ea <strncmp+0x17>
		n--, p++, q++;
  8008e4:	83 c0 01             	add    $0x1,%eax
  8008e7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ea:	39 d8                	cmp    %ebx,%eax
  8008ec:	74 15                	je     800903 <strncmp+0x30>
  8008ee:	0f b6 08             	movzbl (%eax),%ecx
  8008f1:	84 c9                	test   %cl,%cl
  8008f3:	74 04                	je     8008f9 <strncmp+0x26>
  8008f5:	3a 0a                	cmp    (%edx),%cl
  8008f7:	74 eb                	je     8008e4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f9:	0f b6 00             	movzbl (%eax),%eax
  8008fc:	0f b6 12             	movzbl (%edx),%edx
  8008ff:	29 d0                	sub    %edx,%eax
  800901:	eb 05                	jmp    800908 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800908:	5b                   	pop    %ebx
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800915:	eb 07                	jmp    80091e <strchr+0x13>
		if (*s == c)
  800917:	38 ca                	cmp    %cl,%dl
  800919:	74 0f                	je     80092a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091b:	83 c0 01             	add    $0x1,%eax
  80091e:	0f b6 10             	movzbl (%eax),%edx
  800921:	84 d2                	test   %dl,%dl
  800923:	75 f2                	jne    800917 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800936:	eb 03                	jmp    80093b <strfind+0xf>
  800938:	83 c0 01             	add    $0x1,%eax
  80093b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	74 04                	je     800946 <strfind+0x1a>
  800942:	84 d2                	test   %dl,%dl
  800944:	75 f2                	jne    800938 <strfind+0xc>
			break;
	return (char *) s;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800954:	85 c9                	test   %ecx,%ecx
  800956:	74 36                	je     80098e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800958:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095e:	75 28                	jne    800988 <memset+0x40>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	75 23                	jne    800988 <memset+0x40>
		c &= 0xFF;
  800965:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800969:	89 d3                	mov    %edx,%ebx
  80096b:	c1 e3 08             	shl    $0x8,%ebx
  80096e:	89 d6                	mov    %edx,%esi
  800970:	c1 e6 18             	shl    $0x18,%esi
  800973:	89 d0                	mov    %edx,%eax
  800975:	c1 e0 10             	shl    $0x10,%eax
  800978:	09 f0                	or     %esi,%eax
  80097a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80097c:	89 d8                	mov    %ebx,%eax
  80097e:	09 d0                	or     %edx,%eax
  800980:	c1 e9 02             	shr    $0x2,%ecx
  800983:	fc                   	cld    
  800984:	f3 ab                	rep stos %eax,%es:(%edi)
  800986:	eb 06                	jmp    80098e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098b:	fc                   	cld    
  80098c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098e:	89 f8                	mov    %edi,%eax
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5f                   	pop    %edi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a3:	39 c6                	cmp    %eax,%esi
  8009a5:	73 35                	jae    8009dc <memmove+0x47>
  8009a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009aa:	39 d0                	cmp    %edx,%eax
  8009ac:	73 2e                	jae    8009dc <memmove+0x47>
		s += n;
		d += n;
  8009ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 d6                	mov    %edx,%esi
  8009b3:	09 fe                	or     %edi,%esi
  8009b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bb:	75 13                	jne    8009d0 <memmove+0x3b>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 0e                	jne    8009d0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c2:	83 ef 04             	sub    $0x4,%edi
  8009c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
  8009cb:	fd                   	std    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 09                	jmp    8009d9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d0:	83 ef 01             	sub    $0x1,%edi
  8009d3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d6:	fd                   	std    
  8009d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d9:	fc                   	cld    
  8009da:	eb 1d                	jmp    8009f9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dc:	89 f2                	mov    %esi,%edx
  8009de:	09 c2                	or     %eax,%edx
  8009e0:	f6 c2 03             	test   $0x3,%dl
  8009e3:	75 0f                	jne    8009f4 <memmove+0x5f>
  8009e5:	f6 c1 03             	test   $0x3,%cl
  8009e8:	75 0a                	jne    8009f4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ea:	c1 e9 02             	shr    $0x2,%ecx
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f2:	eb 05                	jmp    8009f9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f4:	89 c7                	mov    %eax,%edi
  8009f6:	fc                   	cld    
  8009f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f9:	5e                   	pop    %esi
  8009fa:	5f                   	pop    %edi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a00:	ff 75 10             	pushl  0x10(%ebp)
  800a03:	ff 75 0c             	pushl  0xc(%ebp)
  800a06:	ff 75 08             	pushl  0x8(%ebp)
  800a09:	e8 87 ff ff ff       	call   800995 <memmove>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1b:	89 c6                	mov    %eax,%esi
  800a1d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a20:	eb 1a                	jmp    800a3c <memcmp+0x2c>
		if (*s1 != *s2)
  800a22:	0f b6 08             	movzbl (%eax),%ecx
  800a25:	0f b6 1a             	movzbl (%edx),%ebx
  800a28:	38 d9                	cmp    %bl,%cl
  800a2a:	74 0a                	je     800a36 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a2c:	0f b6 c1             	movzbl %cl,%eax
  800a2f:	0f b6 db             	movzbl %bl,%ebx
  800a32:	29 d8                	sub    %ebx,%eax
  800a34:	eb 0f                	jmp    800a45 <memcmp+0x35>
		s1++, s2++;
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3c:	39 f0                	cmp    %esi,%eax
  800a3e:	75 e2                	jne    800a22 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	53                   	push   %ebx
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a50:	89 c1                	mov    %eax,%ecx
  800a52:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a55:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a59:	eb 0a                	jmp    800a65 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5b:	0f b6 10             	movzbl (%eax),%edx
  800a5e:	39 da                	cmp    %ebx,%edx
  800a60:	74 07                	je     800a69 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	39 c8                	cmp    %ecx,%eax
  800a67:	72 f2                	jb     800a5b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	eb 03                	jmp    800a7d <strtol+0x11>
		s++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7d:	0f b6 01             	movzbl (%ecx),%eax
  800a80:	3c 20                	cmp    $0x20,%al
  800a82:	74 f6                	je     800a7a <strtol+0xe>
  800a84:	3c 09                	cmp    $0x9,%al
  800a86:	74 f2                	je     800a7a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a88:	3c 2b                	cmp    $0x2b,%al
  800a8a:	75 0a                	jne    800a96 <strtol+0x2a>
		s++;
  800a8c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a94:	eb 11                	jmp    800aa7 <strtol+0x3b>
  800a96:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9b:	3c 2d                	cmp    $0x2d,%al
  800a9d:	75 08                	jne    800aa7 <strtol+0x3b>
		s++, neg = 1;
  800a9f:	83 c1 01             	add    $0x1,%ecx
  800aa2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aad:	75 15                	jne    800ac4 <strtol+0x58>
  800aaf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab2:	75 10                	jne    800ac4 <strtol+0x58>
  800ab4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab8:	75 7c                	jne    800b36 <strtol+0xca>
		s += 2, base = 16;
  800aba:	83 c1 02             	add    $0x2,%ecx
  800abd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac2:	eb 16                	jmp    800ada <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac4:	85 db                	test   %ebx,%ebx
  800ac6:	75 12                	jne    800ada <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad0:	75 08                	jne    800ada <strtol+0x6e>
		s++, base = 8;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae2:	0f b6 11             	movzbl (%ecx),%edx
  800ae5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae8:	89 f3                	mov    %esi,%ebx
  800aea:	80 fb 09             	cmp    $0x9,%bl
  800aed:	77 08                	ja     800af7 <strtol+0x8b>
			dig = *s - '0';
  800aef:	0f be d2             	movsbl %dl,%edx
  800af2:	83 ea 30             	sub    $0x30,%edx
  800af5:	eb 22                	jmp    800b19 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 19             	cmp    $0x19,%bl
  800aff:	77 08                	ja     800b09 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 57             	sub    $0x57,%edx
  800b07:	eb 10                	jmp    800b19 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b09:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 16                	ja     800b29 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b19:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b1c:	7d 0b                	jge    800b29 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b25:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b27:	eb b9                	jmp    800ae2 <strtol+0x76>

	if (endptr)
  800b29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2d:	74 0d                	je     800b3c <strtol+0xd0>
		*endptr = (char *) s;
  800b2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b32:	89 0e                	mov    %ecx,(%esi)
  800b34:	eb 06                	jmp    800b3c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b36:	85 db                	test   %ebx,%ebx
  800b38:	74 98                	je     800ad2 <strtol+0x66>
  800b3a:	eb 9e                	jmp    800ada <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b3c:	89 c2                	mov    %eax,%edx
  800b3e:	f7 da                	neg    %edx
  800b40:	85 ff                	test   %edi,%edi
  800b42:	0f 45 c2             	cmovne %edx,%eax
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    
  800b4a:	66 90                	xchg   %ax,%ax
  800b4c:	66 90                	xchg   %ax,%ax
  800b4e:	66 90                	xchg   %ax,%ax

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
