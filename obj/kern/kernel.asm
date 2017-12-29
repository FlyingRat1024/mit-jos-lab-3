
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 10 db 17 f0       	mov    $0xf017db10,%eax
f010004b:	2d ee cb 17 f0       	sub    $0xf017cbee,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 ee cb 17 f0       	push   $0xf017cbee
f0100058:	e8 b1 42 00 00       	call   f010430e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 9d 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 a0 47 10 f0       	push   $0xf01047a0
f010006f:	e8 da 2e 00 00       	call   f0102f4e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 ab 0f 00 00       	call   f0101024 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 10 29 00 00       	call   f010298e <env_init>
	trap_init();
f010007e:	e8 3c 2f 00 00       	call   f0102fbf <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 7e 1b 13 f0       	push   $0xf0131b7e
f010008d:	e8 c7 2a 00 00       	call   f0102b59 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 4c ce 17 f0    	pushl  0xf017ce4c
f010009b:	e8 e5 2d 00 00       	call   f0102e85 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 00 db 17 f0 00 	cmpl   $0x0,0xf017db00
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 00 db 17 f0    	mov    %esi,0xf017db00

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 bb 47 10 f0       	push   $0xf01047bb
f01000ca:	e8 7f 2e 00 00       	call   f0102f4e <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 4f 2e 00 00       	call   f0102f28 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 69 4f 10 f0 	movl   $0xf0104f69,(%esp)
f01000e0:	e8 69 2e 00 00       	call   f0102f4e <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 ba 06 00 00       	call   f01007ac <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 d3 47 10 f0       	push   $0xf01047d3
f010010c:	e8 3d 2e 00 00       	call   f0102f4e <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 0b 2e 00 00       	call   f0102f28 <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 69 4f 10 f0 	movl   $0xf0104f69,(%esp)
f0100124:	e8 25 2e 00 00       	call   f0102f4e <cprintf>
	va_end(ap);
}
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 0b                	je     f0100149 <serial_proc_data+0x18>
f010013e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100143:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100144:	0f b6 c0             	movzbl %al,%eax
f0100147:	eb 05                	jmp    f010014e <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014e:	5d                   	pop    %ebp
f010014f:	c3                   	ret    

f0100150 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 04             	sub    $0x4,%esp
f0100157:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100159:	eb 2b                	jmp    f0100186 <cons_intr+0x36>
		if (c == 0)
f010015b:	85 c0                	test   %eax,%eax
f010015d:	74 27                	je     f0100186 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010015f:	8b 0d 24 ce 17 f0    	mov    0xf017ce24,%ecx
f0100165:	8d 51 01             	lea    0x1(%ecx),%edx
f0100168:	89 15 24 ce 17 f0    	mov    %edx,0xf017ce24
f010016e:	88 81 20 cc 17 f0    	mov    %al,-0xfe833e0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100174:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017a:	75 0a                	jne    f0100186 <cons_intr+0x36>
			cons.wpos = 0;
f010017c:	c7 05 24 ce 17 f0 00 	movl   $0x0,0xf017ce24
f0100183:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100186:	ff d3                	call   *%ebx
f0100188:	83 f8 ff             	cmp    $0xffffffff,%eax
f010018b:	75 ce                	jne    f010015b <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018d:	83 c4 04             	add    $0x4,%esp
f0100190:	5b                   	pop    %ebx
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <kbd_proc_data>:
f0100193:	ba 64 00 00 00       	mov    $0x64,%edx
f0100198:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100199:	a8 01                	test   $0x1,%al
f010019b:	0f 84 f0 00 00 00    	je     f0100291 <kbd_proc_data+0xfe>
f01001a1:	ba 60 00 00 00       	mov    $0x60,%edx
f01001a6:	ec                   	in     (%dx),%al
f01001a7:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001a9:	3c e0                	cmp    $0xe0,%al
f01001ab:	75 0d                	jne    f01001ba <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001ad:	83 0d 00 cc 17 f0 40 	orl    $0x40,0xf017cc00
		return 0;
f01001b4:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001b9:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ba:	55                   	push   %ebp
f01001bb:	89 e5                	mov    %esp,%ebp
f01001bd:	53                   	push   %ebx
f01001be:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c1:	84 c0                	test   %al,%al
f01001c3:	79 36                	jns    f01001fb <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001c5:	8b 0d 00 cc 17 f0    	mov    0xf017cc00,%ecx
f01001cb:	89 cb                	mov    %ecx,%ebx
f01001cd:	83 e3 40             	and    $0x40,%ebx
f01001d0:	83 e0 7f             	and    $0x7f,%eax
f01001d3:	85 db                	test   %ebx,%ebx
f01001d5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001d8:	0f b6 d2             	movzbl %dl,%edx
f01001db:	0f b6 82 40 49 10 f0 	movzbl -0xfefb6c0(%edx),%eax
f01001e2:	83 c8 40             	or     $0x40,%eax
f01001e5:	0f b6 c0             	movzbl %al,%eax
f01001e8:	f7 d0                	not    %eax
f01001ea:	21 c8                	and    %ecx,%eax
f01001ec:	a3 00 cc 17 f0       	mov    %eax,0xf017cc00
		return 0;
f01001f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f6:	e9 9e 00 00 00       	jmp    f0100299 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001fb:	8b 0d 00 cc 17 f0    	mov    0xf017cc00,%ecx
f0100201:	f6 c1 40             	test   $0x40,%cl
f0100204:	74 0e                	je     f0100214 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100206:	83 c8 80             	or     $0xffffff80,%eax
f0100209:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010020b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010020e:	89 0d 00 cc 17 f0    	mov    %ecx,0xf017cc00
	}

	shift |= shiftcode[data];
f0100214:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100217:	0f b6 82 40 49 10 f0 	movzbl -0xfefb6c0(%edx),%eax
f010021e:	0b 05 00 cc 17 f0    	or     0xf017cc00,%eax
f0100224:	0f b6 8a 40 48 10 f0 	movzbl -0xfefb7c0(%edx),%ecx
f010022b:	31 c8                	xor    %ecx,%eax
f010022d:	a3 00 cc 17 f0       	mov    %eax,0xf017cc00

	c = charcode[shift & (CTL | SHIFT)][data];
f0100232:	89 c1                	mov    %eax,%ecx
f0100234:	83 e1 03             	and    $0x3,%ecx
f0100237:	8b 0c 8d 20 48 10 f0 	mov    -0xfefb7e0(,%ecx,4),%ecx
f010023e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100242:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100245:	a8 08                	test   $0x8,%al
f0100247:	74 1b                	je     f0100264 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100249:	89 da                	mov    %ebx,%edx
f010024b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010024e:	83 f9 19             	cmp    $0x19,%ecx
f0100251:	77 05                	ja     f0100258 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100253:	83 eb 20             	sub    $0x20,%ebx
f0100256:	eb 0c                	jmp    f0100264 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100258:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010025b:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010025e:	83 fa 19             	cmp    $0x19,%edx
f0100261:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100264:	f7 d0                	not    %eax
f0100266:	a8 06                	test   $0x6,%al
f0100268:	75 2d                	jne    f0100297 <kbd_proc_data+0x104>
f010026a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100270:	75 25                	jne    f0100297 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100272:	83 ec 0c             	sub    $0xc,%esp
f0100275:	68 ed 47 10 f0       	push   $0xf01047ed
f010027a:	e8 cf 2c 00 00       	call   f0102f4e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010027f:	ba 92 00 00 00       	mov    $0x92,%edx
f0100284:	b8 03 00 00 00       	mov    $0x3,%eax
f0100289:	ee                   	out    %al,(%dx)
f010028a:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010028d:	89 d8                	mov    %ebx,%eax
f010028f:	eb 08                	jmp    f0100299 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100296:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100297:	89 d8                	mov    %ebx,%eax
}
f0100299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010029c:	c9                   	leave  
f010029d:	c3                   	ret    

f010029e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010029e:	55                   	push   %ebp
f010029f:	89 e5                	mov    %esp,%ebp
f01002a1:	57                   	push   %edi
f01002a2:	56                   	push   %esi
f01002a3:	53                   	push   %ebx
f01002a4:	83 ec 1c             	sub    $0x1c,%esp
f01002a7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a9:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ae:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002b3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b8:	eb 09                	jmp    f01002c3 <cons_putc+0x25>
f01002ba:	89 ca                	mov    %ecx,%edx
f01002bc:	ec                   	in     (%dx),%al
f01002bd:	ec                   	in     (%dx),%al
f01002be:	ec                   	in     (%dx),%al
f01002bf:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002c0:	83 c3 01             	add    $0x1,%ebx
f01002c3:	89 f2                	mov    %esi,%edx
f01002c5:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002c6:	a8 20                	test   $0x20,%al
f01002c8:	75 08                	jne    f01002d2 <cons_putc+0x34>
f01002ca:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002d0:	7e e8                	jle    f01002ba <cons_putc+0x1c>
f01002d2:	89 f8                	mov    %edi,%eax
f01002d4:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002dc:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002dd:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e2:	be 79 03 00 00       	mov    $0x379,%esi
f01002e7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002ec:	eb 09                	jmp    f01002f7 <cons_putc+0x59>
f01002ee:	89 ca                	mov    %ecx,%edx
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	ec                   	in     (%dx),%al
f01002f4:	83 c3 01             	add    $0x1,%ebx
f01002f7:	89 f2                	mov    %esi,%edx
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100300:	7f 04                	jg     f0100306 <cons_putc+0x68>
f0100302:	84 c0                	test   %al,%al
f0100304:	79 e8                	jns    f01002ee <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100306:	ba 78 03 00 00       	mov    $0x378,%edx
f010030b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010030f:	ee                   	out    %al,(%dx)
f0100310:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100315:	b8 0d 00 00 00       	mov    $0xd,%eax
f010031a:	ee                   	out    %al,(%dx)
f010031b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100320:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100321:	89 fa                	mov    %edi,%edx
f0100323:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100329:	89 f8                	mov    %edi,%eax
f010032b:	80 cc 07             	or     $0x7,%ah
f010032e:	85 d2                	test   %edx,%edx
f0100330:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100333:	89 f8                	mov    %edi,%eax
f0100335:	0f b6 c0             	movzbl %al,%eax
f0100338:	83 f8 09             	cmp    $0x9,%eax
f010033b:	74 74                	je     f01003b1 <cons_putc+0x113>
f010033d:	83 f8 09             	cmp    $0x9,%eax
f0100340:	7f 0a                	jg     f010034c <cons_putc+0xae>
f0100342:	83 f8 08             	cmp    $0x8,%eax
f0100345:	74 14                	je     f010035b <cons_putc+0xbd>
f0100347:	e9 99 00 00 00       	jmp    f01003e5 <cons_putc+0x147>
f010034c:	83 f8 0a             	cmp    $0xa,%eax
f010034f:	74 3a                	je     f010038b <cons_putc+0xed>
f0100351:	83 f8 0d             	cmp    $0xd,%eax
f0100354:	74 3d                	je     f0100393 <cons_putc+0xf5>
f0100356:	e9 8a 00 00 00       	jmp    f01003e5 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010035b:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f0100362:	66 85 c0             	test   %ax,%ax
f0100365:	0f 84 e6 00 00 00    	je     f0100451 <cons_putc+0x1b3>
			crt_pos--;
f010036b:	83 e8 01             	sub    $0x1,%eax
f010036e:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100374:	0f b7 c0             	movzwl %ax,%eax
f0100377:	66 81 e7 00 ff       	and    $0xff00,%di
f010037c:	83 cf 20             	or     $0x20,%edi
f010037f:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f0100385:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100389:	eb 78                	jmp    f0100403 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038b:	66 83 05 28 ce 17 f0 	addw   $0x50,0xf017ce28
f0100392:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100393:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f010039a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a0:	c1 e8 16             	shr    $0x16,%eax
f01003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a6:	c1 e0 04             	shl    $0x4,%eax
f01003a9:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
f01003af:	eb 52                	jmp    f0100403 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b6:	e8 e3 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003bb:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c0:	e8 d9 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003c5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ca:	e8 cf fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d4:	e8 c5 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003de:	e8 bb fe ff ff       	call   f010029e <cons_putc>
f01003e3:	eb 1e                	jmp    f0100403 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e5:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f01003ec:	8d 50 01             	lea    0x1(%eax),%edx
f01003ef:	66 89 15 28 ce 17 f0 	mov    %dx,0xf017ce28
f01003f6:	0f b7 c0             	movzwl %ax,%eax
f01003f9:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f01003ff:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100403:	66 81 3d 28 ce 17 f0 	cmpw   $0x7cf,0xf017ce28
f010040a:	cf 07 
f010040c:	76 43                	jbe    f0100451 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040e:	a1 2c ce 17 f0       	mov    0xf017ce2c,%eax
f0100413:	83 ec 04             	sub    $0x4,%esp
f0100416:	68 00 0f 00 00       	push   $0xf00
f010041b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100421:	52                   	push   %edx
f0100422:	50                   	push   %eax
f0100423:	e8 33 3f 00 00       	call   f010435b <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100428:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f010042e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100434:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010043a:	83 c4 10             	add    $0x10,%esp
f010043d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100442:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100445:	39 d0                	cmp    %edx,%eax
f0100447:	75 f4                	jne    f010043d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100449:	66 83 2d 28 ce 17 f0 	subw   $0x50,0xf017ce28
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 30 ce 17 f0    	mov    0xf017ce30,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 28 ce 17 f0 	movzwl 0xf017ce28,%ebx
f0100466:	8d 71 01             	lea    0x1(%ecx),%esi
f0100469:	89 d8                	mov    %ebx,%eax
f010046b:	66 c1 e8 08          	shr    $0x8,%ax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100477:	89 ca                	mov    %ecx,%edx
f0100479:	ee                   	out    %al,(%dx)
f010047a:	89 d8                	mov    %ebx,%eax
f010047c:	89 f2                	mov    %esi,%edx
f010047e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);//输出到打印机
	cga_putc(c);//输出到显示器
}
f010047f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100482:	5b                   	pop    %ebx
f0100483:	5e                   	pop    %esi
f0100484:	5f                   	pop    %edi
f0100485:	5d                   	pop    %ebp
f0100486:	c3                   	ret    

f0100487 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100487:	80 3d 34 ce 17 f0 00 	cmpb   $0x0,0xf017ce34
f010048e:	74 11                	je     f01004a1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100490:	55                   	push   %ebp
f0100491:	89 e5                	mov    %esp,%ebp
f0100493:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100496:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f010049b:	e8 b0 fc ff ff       	call   f0100150 <cons_intr>
}
f01004a0:	c9                   	leave  
f01004a1:	f3 c3                	repz ret 

f01004a3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a3:	55                   	push   %ebp
f01004a4:	89 e5                	mov    %esp,%ebp
f01004a6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a9:	b8 93 01 10 f0       	mov    $0xf0100193,%eax
f01004ae:	e8 9d fc ff ff       	call   f0100150 <cons_intr>
}
f01004b3:	c9                   	leave  
f01004b4:	c3                   	ret    

f01004b5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b5:	55                   	push   %ebp
f01004b6:	89 e5                	mov    %esp,%ebp
f01004b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004bb:	e8 c7 ff ff ff       	call   f0100487 <serial_intr>
	kbd_intr();
f01004c0:	e8 de ff ff ff       	call   f01004a3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c5:	a1 20 ce 17 f0       	mov    0xf017ce20,%eax
f01004ca:	3b 05 24 ce 17 f0    	cmp    0xf017ce24,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 20 ce 17 f0    	mov    %edx,0xf017ce20
f01004db:	0f b6 88 20 cc 17 f0 	movzbl -0xfe833e0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004e2:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ea:	75 11                	jne    f01004fd <cons_getc+0x48>
			cons.rpos = 0;
f01004ec:	c7 05 20 ce 17 f0 00 	movl   $0x0,0xf017ce20
f01004f3:	00 00 00 
f01004f6:	eb 05                	jmp    f01004fd <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fd:	c9                   	leave  
f01004fe:	c3                   	ret    

f01004ff <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ff:	55                   	push   %ebp
f0100500:	89 e5                	mov    %esp,%ebp
f0100502:	57                   	push   %edi
f0100503:	56                   	push   %esi
f0100504:	53                   	push   %ebx
f0100505:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100508:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100516:	5a a5 
	if (*cp != 0xA55A) {
f0100518:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100523:	74 11                	je     f0100536 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100525:	c7 05 30 ce 17 f0 b4 	movl   $0x3b4,0xf017ce30
f010052c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100534:	eb 16                	jmp    f010054c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100536:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053d:	c7 05 30 ce 17 f0 d4 	movl   $0x3d4,0xf017ce30
f0100544:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100547:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010054c:	8b 3d 30 ce 17 f0    	mov    0xf017ce30,%edi
f0100552:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100557:	89 fa                	mov    %edi,%edx
f0100559:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055a:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055d:	89 da                	mov    %ebx,%edx
f010055f:	ec                   	in     (%dx),%al
f0100560:	0f b6 c8             	movzbl %al,%ecx
f0100563:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100566:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056b:	89 fa                	mov    %edi,%edx
f010056d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056e:	89 da                	mov    %ebx,%edx
f0100570:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100571:	89 35 2c ce 17 f0    	mov    %esi,0xf017ce2c
	crt_pos = pos;
f0100577:	0f b6 c0             	movzbl %al,%eax
f010057a:	09 c8                	or     %ecx,%eax
f010057c:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100582:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100587:	b8 00 00 00 00       	mov    $0x0,%eax
f010058c:	89 f2                	mov    %esi,%edx
f010058e:	ee                   	out    %al,(%dx)
f010058f:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100594:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100599:	ee                   	out    %al,(%dx)
f010059a:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010059f:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a4:	89 da                	mov    %ebx,%edx
f01005a6:	ee                   	out    %al,(%dx)
f01005a7:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b7:	b8 03 00 00 00       	mov    $0x3,%eax
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01005d2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d8:	ec                   	in     (%dx),%al
f01005d9:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005db:	3c ff                	cmp    $0xff,%al
f01005dd:	0f 95 05 34 ce 17 f0 	setne  0xf017ce34
f01005e4:	89 f2                	mov    %esi,%edx
f01005e6:	ec                   	in     (%dx),%al
f01005e7:	89 da                	mov    %ebx,%edx
f01005e9:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005ea:	80 f9 ff             	cmp    $0xff,%cl
f01005ed:	75 10                	jne    f01005ff <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005ef:	83 ec 0c             	sub    $0xc,%esp
f01005f2:	68 f9 47 10 f0       	push   $0xf01047f9
f01005f7:	e8 52 29 00 00       	call   f0102f4e <cprintf>
f01005fc:	83 c4 10             	add    $0x10,%esp
}
f01005ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5e                   	pop    %esi
f0100604:	5f                   	pop    %edi
f0100605:	5d                   	pop    %ebp
f0100606:	c3                   	ret    

f0100607 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100607:	55                   	push   %ebp
f0100608:	89 e5                	mov    %esp,%ebp
f010060a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010060d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100610:	e8 89 fc ff ff       	call   f010029e <cons_putc>
}
f0100615:	c9                   	leave  
f0100616:	c3                   	ret    

f0100617 <getchar>:

int
getchar(void)
{
f0100617:	55                   	push   %ebp
f0100618:	89 e5                	mov    %esp,%ebp
f010061a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010061d:	e8 93 fe ff ff       	call   f01004b5 <cons_getc>
f0100622:	85 c0                	test   %eax,%eax
f0100624:	74 f7                	je     f010061d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <iscons>:

int
iscons(int fdnum)
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010062b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100630:	5d                   	pop    %ebp
f0100631:	c3                   	ret    

f0100632 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100638:	68 40 4a 10 f0       	push   $0xf0104a40
f010063d:	68 5e 4a 10 f0       	push   $0xf0104a5e
f0100642:	68 63 4a 10 f0       	push   $0xf0104a63
f0100647:	e8 02 29 00 00       	call   f0102f4e <cprintf>
f010064c:	83 c4 0c             	add    $0xc,%esp
f010064f:	68 14 4b 10 f0       	push   $0xf0104b14
f0100654:	68 6c 4a 10 f0       	push   $0xf0104a6c
f0100659:	68 63 4a 10 f0       	push   $0xf0104a63
f010065e:	e8 eb 28 00 00       	call   f0102f4e <cprintf>
	return 0;
}
f0100663:	b8 00 00 00 00       	mov    $0x0,%eax
f0100668:	c9                   	leave  
f0100669:	c3                   	ret    

f010066a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010066a:	55                   	push   %ebp
f010066b:	89 e5                	mov    %esp,%ebp
f010066d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100670:	68 75 4a 10 f0       	push   $0xf0104a75
f0100675:	e8 d4 28 00 00       	call   f0102f4e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010067a:	83 c4 08             	add    $0x8,%esp
f010067d:	68 0c 00 10 00       	push   $0x10000c
f0100682:	68 3c 4b 10 f0       	push   $0xf0104b3c
f0100687:	e8 c2 28 00 00       	call   f0102f4e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068c:	83 c4 0c             	add    $0xc,%esp
f010068f:	68 0c 00 10 00       	push   $0x10000c
f0100694:	68 0c 00 10 f0       	push   $0xf010000c
f0100699:	68 64 4b 10 f0       	push   $0xf0104b64
f010069e:	e8 ab 28 00 00       	call   f0102f4e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a3:	83 c4 0c             	add    $0xc,%esp
f01006a6:	68 91 47 10 00       	push   $0x104791
f01006ab:	68 91 47 10 f0       	push   $0xf0104791
f01006b0:	68 88 4b 10 f0       	push   $0xf0104b88
f01006b5:	e8 94 28 00 00       	call   f0102f4e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ba:	83 c4 0c             	add    $0xc,%esp
f01006bd:	68 ee cb 17 00       	push   $0x17cbee
f01006c2:	68 ee cb 17 f0       	push   $0xf017cbee
f01006c7:	68 ac 4b 10 f0       	push   $0xf0104bac
f01006cc:	e8 7d 28 00 00       	call   f0102f4e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006d1:	83 c4 0c             	add    $0xc,%esp
f01006d4:	68 10 db 17 00       	push   $0x17db10
f01006d9:	68 10 db 17 f0       	push   $0xf017db10
f01006de:	68 d0 4b 10 f0       	push   $0xf0104bd0
f01006e3:	e8 66 28 00 00       	call   f0102f4e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006e8:	b8 0f df 17 f0       	mov    $0xf017df0f,%eax
f01006ed:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006f2:	83 c4 08             	add    $0x8,%esp
f01006f5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006fa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100700:	85 c0                	test   %eax,%eax
f0100702:	0f 48 c2             	cmovs  %edx,%eax
f0100705:	c1 f8 0a             	sar    $0xa,%eax
f0100708:	50                   	push   %eax
f0100709:	68 f4 4b 10 f0       	push   $0xf0104bf4
f010070e:	e8 3b 28 00 00       	call   f0102f4e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100713:	b8 00 00 00 00       	mov    $0x0,%eax
f0100718:	c9                   	leave  
f0100719:	c3                   	ret    

f010071a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010071a:	55                   	push   %ebp
f010071b:	89 e5                	mov    %esp,%ebp
f010071d:	57                   	push   %edi
f010071e:	56                   	push   %esi
f010071f:	53                   	push   %ebx
f0100720:	83 ec 38             	sub    $0x38,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100723:	89 ee                	mov    %ebp,%esi
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();
	cprintf("Stack backtrace:\n");
f0100725:	68 8e 4a 10 f0       	push   $0xf0104a8e
f010072a:	e8 1f 28 00 00       	call   f0102f4e <cprintf>
	while (ebp) {
f010072f:	83 c4 10             	add    $0x10,%esp
f0100732:	eb 67                	jmp    f010079b <mon_backtrace+0x81>
	    cprintf(" ebp %08x eip %08x args ", ebp, ebp[1]);
f0100734:	83 ec 04             	sub    $0x4,%esp
f0100737:	ff 76 04             	pushl  0x4(%esi)
f010073a:	56                   	push   %esi
f010073b:	68 a0 4a 10 f0       	push   $0xf0104aa0
f0100740:	e8 09 28 00 00       	call   f0102f4e <cprintf>
f0100745:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100748:	8d 7e 1c             	lea    0x1c(%esi),%edi
f010074b:	83 c4 10             	add    $0x10,%esp
	    for (int j = 2; j != 7; ++j) {
		cprintf(" %08x", ebp[j]);   
f010074e:	83 ec 08             	sub    $0x8,%esp
f0100751:	ff 33                	pushl  (%ebx)
f0100753:	68 b9 4a 10 f0       	push   $0xf0104ab9
f0100758:	e8 f1 27 00 00       	call   f0102f4e <cprintf>
f010075d:	83 c3 04             	add    $0x4,%ebx
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
	    cprintf(" ebp %08x eip %08x args ", ebp, ebp[1]);
	    for (int j = 2; j != 7; ++j) {
f0100760:	83 c4 10             	add    $0x10,%esp
f0100763:	39 fb                	cmp    %edi,%ebx
f0100765:	75 e7                	jne    f010074e <mon_backtrace+0x34>
		cprintf(" %08x", ebp[j]);   
	    }
	    debuginfo_eip(ebp[1], &info);
f0100767:	83 ec 08             	sub    $0x8,%esp
f010076a:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010076d:	50                   	push   %eax
f010076e:	ff 76 04             	pushl  0x4(%esi)
f0100771:	e8 3d 31 00 00       	call   f01038b3 <debuginfo_eip>
    	    cprintf("\n     %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ebp[1] - info.eip_fn_addr);
f0100776:	83 c4 08             	add    $0x8,%esp
f0100779:	8b 46 04             	mov    0x4(%esi),%eax
f010077c:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010077f:	50                   	push   %eax
f0100780:	ff 75 d8             	pushl  -0x28(%ebp)
f0100783:	ff 75 dc             	pushl  -0x24(%ebp)
f0100786:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100789:	ff 75 d0             	pushl  -0x30(%ebp)
f010078c:	68 bf 4a 10 f0       	push   $0xf0104abf
f0100791:	e8 b8 27 00 00       	call   f0102f4e <cprintf>
	    ebp = (uint32_t *) (*ebp);
f0100796:	8b 36                	mov    (%esi),%esi
f0100798:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f010079b:	85 f6                	test   %esi,%esi
f010079d:	75 95                	jne    f0100734 <mon_backtrace+0x1a>
    	    cprintf("\n     %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ebp[1] - info.eip_fn_addr);
	    ebp = (uint32_t *) (*ebp);
}
return 0;
	return 0;
}
f010079f:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a7:	5b                   	pop    %ebx
f01007a8:	5e                   	pop    %esi
f01007a9:	5f                   	pop    %edi
f01007aa:	5d                   	pop    %ebp
f01007ab:	c3                   	ret    

f01007ac <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ac:	55                   	push   %ebp
f01007ad:	89 e5                	mov    %esp,%ebp
f01007af:	57                   	push   %edi
f01007b0:	56                   	push   %esi
f01007b1:	53                   	push   %ebx
f01007b2:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007b5:	68 20 4c 10 f0       	push   $0xf0104c20
f01007ba:	e8 8f 27 00 00       	call   f0102f4e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007bf:	c7 04 24 44 4c 10 f0 	movl   $0xf0104c44,(%esp)
f01007c6:	e8 83 27 00 00       	call   f0102f4e <cprintf>

	if (tf != NULL)
f01007cb:	83 c4 10             	add    $0x10,%esp
f01007ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007d2:	74 0e                	je     f01007e2 <monitor+0x36>
		print_trapframe(tf);
f01007d4:	83 ec 0c             	sub    $0xc,%esp
f01007d7:	ff 75 08             	pushl  0x8(%ebp)
f01007da:	e8 a9 2b 00 00       	call   f0103388 <print_trapframe>
f01007df:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01007e2:	83 ec 0c             	sub    $0xc,%esp
f01007e5:	68 d5 4a 10 f0       	push   $0xf0104ad5
f01007ea:	e8 c8 38 00 00       	call   f01040b7 <readline>
f01007ef:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007f1:	83 c4 10             	add    $0x10,%esp
f01007f4:	85 c0                	test   %eax,%eax
f01007f6:	74 ea                	je     f01007e2 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007f8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007ff:	be 00 00 00 00       	mov    $0x0,%esi
f0100804:	eb 0a                	jmp    f0100810 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100806:	c6 03 00             	movb   $0x0,(%ebx)
f0100809:	89 f7                	mov    %esi,%edi
f010080b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010080e:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100810:	0f b6 03             	movzbl (%ebx),%eax
f0100813:	84 c0                	test   %al,%al
f0100815:	74 63                	je     f010087a <monitor+0xce>
f0100817:	83 ec 08             	sub    $0x8,%esp
f010081a:	0f be c0             	movsbl %al,%eax
f010081d:	50                   	push   %eax
f010081e:	68 d9 4a 10 f0       	push   $0xf0104ad9
f0100823:	e8 a9 3a 00 00       	call   f01042d1 <strchr>
f0100828:	83 c4 10             	add    $0x10,%esp
f010082b:	85 c0                	test   %eax,%eax
f010082d:	75 d7                	jne    f0100806 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010082f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100832:	74 46                	je     f010087a <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100834:	83 fe 0f             	cmp    $0xf,%esi
f0100837:	75 14                	jne    f010084d <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100839:	83 ec 08             	sub    $0x8,%esp
f010083c:	6a 10                	push   $0x10
f010083e:	68 de 4a 10 f0       	push   $0xf0104ade
f0100843:	e8 06 27 00 00       	call   f0102f4e <cprintf>
f0100848:	83 c4 10             	add    $0x10,%esp
f010084b:	eb 95                	jmp    f01007e2 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010084d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100850:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100854:	eb 03                	jmp    f0100859 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100856:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100859:	0f b6 03             	movzbl (%ebx),%eax
f010085c:	84 c0                	test   %al,%al
f010085e:	74 ae                	je     f010080e <monitor+0x62>
f0100860:	83 ec 08             	sub    $0x8,%esp
f0100863:	0f be c0             	movsbl %al,%eax
f0100866:	50                   	push   %eax
f0100867:	68 d9 4a 10 f0       	push   $0xf0104ad9
f010086c:	e8 60 3a 00 00       	call   f01042d1 <strchr>
f0100871:	83 c4 10             	add    $0x10,%esp
f0100874:	85 c0                	test   %eax,%eax
f0100876:	74 de                	je     f0100856 <monitor+0xaa>
f0100878:	eb 94                	jmp    f010080e <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f010087a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100881:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100882:	85 f6                	test   %esi,%esi
f0100884:	0f 84 58 ff ff ff    	je     f01007e2 <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	68 5e 4a 10 f0       	push   $0xf0104a5e
f0100892:	ff 75 a8             	pushl  -0x58(%ebp)
f0100895:	e8 d9 39 00 00       	call   f0104273 <strcmp>
f010089a:	83 c4 10             	add    $0x10,%esp
f010089d:	85 c0                	test   %eax,%eax
f010089f:	74 1e                	je     f01008bf <monitor+0x113>
f01008a1:	83 ec 08             	sub    $0x8,%esp
f01008a4:	68 6c 4a 10 f0       	push   $0xf0104a6c
f01008a9:	ff 75 a8             	pushl  -0x58(%ebp)
f01008ac:	e8 c2 39 00 00       	call   f0104273 <strcmp>
f01008b1:	83 c4 10             	add    $0x10,%esp
f01008b4:	85 c0                	test   %eax,%eax
f01008b6:	75 2f                	jne    f01008e7 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01008bd:	eb 05                	jmp    f01008c4 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008bf:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01008c4:	83 ec 04             	sub    $0x4,%esp
f01008c7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008ca:	01 d0                	add    %edx,%eax
f01008cc:	ff 75 08             	pushl  0x8(%ebp)
f01008cf:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008d2:	51                   	push   %ecx
f01008d3:	56                   	push   %esi
f01008d4:	ff 14 85 74 4c 10 f0 	call   *-0xfefb38c(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008db:	83 c4 10             	add    $0x10,%esp
f01008de:	85 c0                	test   %eax,%eax
f01008e0:	78 1d                	js     f01008ff <monitor+0x153>
f01008e2:	e9 fb fe ff ff       	jmp    f01007e2 <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008e7:	83 ec 08             	sub    $0x8,%esp
f01008ea:	ff 75 a8             	pushl  -0x58(%ebp)
f01008ed:	68 fb 4a 10 f0       	push   $0xf0104afb
f01008f2:	e8 57 26 00 00       	call   f0102f4e <cprintf>
f01008f7:	83 c4 10             	add    $0x10,%esp
f01008fa:	e9 e3 fe ff ff       	jmp    f01007e2 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100902:	5b                   	pop    %ebx
f0100903:	5e                   	pop    %esi
f0100904:	5f                   	pop    %edi
f0100905:	5d                   	pop    %ebp
f0100906:	c3                   	ret    

f0100907 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100907:	55                   	push   %ebp
f0100908:	89 e5                	mov    %esp,%ebp
f010090a:	53                   	push   %ebx
f010090b:	83 ec 04             	sub    $0x4,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010090e:	83 3d 38 ce 17 f0 00 	cmpl   $0x0,0xf017ce38
f0100915:	75 11                	jne    f0100928 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100917:	ba 0f eb 17 f0       	mov    $0xf017eb0f,%edx
f010091c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100922:	89 15 38 ce 17 f0    	mov    %edx,0xf017ce38
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100928:	8b 1d 38 ce 17 f0    	mov    0xf017ce38,%ebx
	nextfree = ROUNDUP(nextfree+n, PGSIZE);
f010092e:	8d 94 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edx
f0100935:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010093b:	89 15 38 ce 17 f0    	mov    %edx,0xf017ce38
	if((uint32_t)nextfree - KERNBASE > (npages*PGSIZE))
f0100941:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100947:	8b 0d 04 db 17 f0    	mov    0xf017db04,%ecx
f010094d:	c1 e1 0c             	shl    $0xc,%ecx
f0100950:	39 ca                	cmp    %ecx,%edx
f0100952:	76 14                	jbe    f0100968 <boot_alloc+0x61>
		panic("Out of memory!\n");
f0100954:	83 ec 04             	sub    $0x4,%esp
f0100957:	68 84 4c 10 f0       	push   $0xf0104c84
f010095c:	6a 69                	push   $0x69
f010095e:	68 94 4c 10 f0       	push   $0xf0104c94
f0100963:	e8 38 f7 ff ff       	call   f01000a0 <_panic>
	return result;
}
f0100968:	89 d8                	mov    %ebx,%eax
f010096a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010096d:	c9                   	leave  
f010096e:	c3                   	ret    

f010096f <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f010096f:	89 d1                	mov    %edx,%ecx
f0100971:	c1 e9 16             	shr    $0x16,%ecx
f0100974:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100977:	a8 01                	test   $0x1,%al
f0100979:	74 52                	je     f01009cd <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010097b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100980:	89 c1                	mov    %eax,%ecx
f0100982:	c1 e9 0c             	shr    $0xc,%ecx
f0100985:	3b 0d 04 db 17 f0    	cmp    0xf017db04,%ecx
f010098b:	72 1b                	jb     f01009a8 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010098d:	55                   	push   %ebp
f010098e:	89 e5                	mov    %esp,%ebp
f0100990:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100993:	50                   	push   %eax
f0100994:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0100999:	68 41 03 00 00       	push   $0x341
f010099e:	68 94 4c 10 f0       	push   $0xf0104c94
f01009a3:	e8 f8 f6 ff ff       	call   f01000a0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009a8:	c1 ea 0c             	shr    $0xc,%edx
f01009ab:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009b1:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009b8:	89 c2                	mov    %eax,%edx
f01009ba:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009c2:	85 d2                	test   %edx,%edx
f01009c4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009c9:	0f 44 c2             	cmove  %edx,%eax
f01009cc:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009d2:	c3                   	ret    

f01009d3 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009d3:	55                   	push   %ebp
f01009d4:	89 e5                	mov    %esp,%ebp
f01009d6:	57                   	push   %edi
f01009d7:	56                   	push   %esi
f01009d8:	53                   	push   %ebx
f01009d9:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009dc:	84 c0                	test   %al,%al
f01009de:	0f 85 72 02 00 00    	jne    f0100c56 <check_page_free_list+0x283>
f01009e4:	e9 7f 02 00 00       	jmp    f0100c68 <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009e9:	83 ec 04             	sub    $0x4,%esp
f01009ec:	68 c0 4f 10 f0       	push   $0xf0104fc0
f01009f1:	68 7f 02 00 00       	push   $0x27f
f01009f6:	68 94 4c 10 f0       	push   $0xf0104c94
f01009fb:	e8 a0 f6 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a00:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a03:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a06:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a09:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a0c:	89 c2                	mov    %eax,%edx
f0100a0e:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0100a14:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a1a:	0f 95 c2             	setne  %dl
f0100a1d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a20:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a24:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a26:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a2a:	8b 00                	mov    (%eax),%eax
f0100a2c:	85 c0                	test   %eax,%eax
f0100a2e:	75 dc                	jne    f0100a0c <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a39:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a3f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a41:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a44:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a49:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a4e:	8b 1d 40 ce 17 f0    	mov    0xf017ce40,%ebx
f0100a54:	eb 53                	jmp    f0100aa9 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a56:	89 d8                	mov    %ebx,%eax
f0100a58:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0100a5e:	c1 f8 03             	sar    $0x3,%eax
f0100a61:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a64:	89 c2                	mov    %eax,%edx
f0100a66:	c1 ea 16             	shr    $0x16,%edx
f0100a69:	39 f2                	cmp    %esi,%edx
f0100a6b:	73 3a                	jae    f0100aa7 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a6d:	89 c2                	mov    %eax,%edx
f0100a6f:	c1 ea 0c             	shr    $0xc,%edx
f0100a72:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100a78:	72 12                	jb     f0100a8c <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a7a:	50                   	push   %eax
f0100a7b:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0100a80:	6a 56                	push   $0x56
f0100a82:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100a87:	e8 14 f6 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a8c:	83 ec 04             	sub    $0x4,%esp
f0100a8f:	68 80 00 00 00       	push   $0x80
f0100a94:	68 97 00 00 00       	push   $0x97
f0100a99:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a9e:	50                   	push   %eax
f0100a9f:	e8 6a 38 00 00       	call   f010430e <memset>
f0100aa4:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aa7:	8b 1b                	mov    (%ebx),%ebx
f0100aa9:	85 db                	test   %ebx,%ebx
f0100aab:	75 a9                	jne    f0100a56 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100aad:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ab2:	e8 50 fe ff ff       	call   f0100907 <boot_alloc>
f0100ab7:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aba:	8b 15 40 ce 17 f0    	mov    0xf017ce40,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ac0:	8b 0d 0c db 17 f0    	mov    0xf017db0c,%ecx
		assert(pp < pages + npages);
f0100ac6:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f0100acb:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ace:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ad1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ad4:	be 00 00 00 00       	mov    $0x0,%esi
f0100ad9:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100adc:	e9 30 01 00 00       	jmp    f0100c11 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ae1:	39 ca                	cmp    %ecx,%edx
f0100ae3:	73 19                	jae    f0100afe <check_page_free_list+0x12b>
f0100ae5:	68 ae 4c 10 f0       	push   $0xf0104cae
f0100aea:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100aef:	68 99 02 00 00       	push   $0x299
f0100af4:	68 94 4c 10 f0       	push   $0xf0104c94
f0100af9:	e8 a2 f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100afe:	39 fa                	cmp    %edi,%edx
f0100b00:	72 19                	jb     f0100b1b <check_page_free_list+0x148>
f0100b02:	68 cf 4c 10 f0       	push   $0xf0104ccf
f0100b07:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b0c:	68 9a 02 00 00       	push   $0x29a
f0100b11:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b16:	e8 85 f5 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b1b:	89 d0                	mov    %edx,%eax
f0100b1d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b20:	a8 07                	test   $0x7,%al
f0100b22:	74 19                	je     f0100b3d <check_page_free_list+0x16a>
f0100b24:	68 e4 4f 10 f0       	push   $0xf0104fe4
f0100b29:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b2e:	68 9b 02 00 00       	push   $0x29b
f0100b33:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b38:	e8 63 f5 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b3d:	c1 f8 03             	sar    $0x3,%eax
f0100b40:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b43:	85 c0                	test   %eax,%eax
f0100b45:	75 19                	jne    f0100b60 <check_page_free_list+0x18d>
f0100b47:	68 e3 4c 10 f0       	push   $0xf0104ce3
f0100b4c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b51:	68 9e 02 00 00       	push   $0x29e
f0100b56:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b5b:	e8 40 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b60:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b65:	75 19                	jne    f0100b80 <check_page_free_list+0x1ad>
f0100b67:	68 f4 4c 10 f0       	push   $0xf0104cf4
f0100b6c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b71:	68 9f 02 00 00       	push   $0x29f
f0100b76:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b7b:	e8 20 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b80:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b85:	75 19                	jne    f0100ba0 <check_page_free_list+0x1cd>
f0100b87:	68 18 50 10 f0       	push   $0xf0105018
f0100b8c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b91:	68 a0 02 00 00       	push   $0x2a0
f0100b96:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b9b:	e8 00 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ba0:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ba5:	75 19                	jne    f0100bc0 <check_page_free_list+0x1ed>
f0100ba7:	68 0d 4d 10 f0       	push   $0xf0104d0d
f0100bac:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100bb1:	68 a1 02 00 00       	push   $0x2a1
f0100bb6:	68 94 4c 10 f0       	push   $0xf0104c94
f0100bbb:	e8 e0 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bc0:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bc5:	76 3f                	jbe    f0100c06 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bc7:	89 c3                	mov    %eax,%ebx
f0100bc9:	c1 eb 0c             	shr    $0xc,%ebx
f0100bcc:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100bcf:	77 12                	ja     f0100be3 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bd1:	50                   	push   %eax
f0100bd2:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0100bd7:	6a 56                	push   $0x56
f0100bd9:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100bde:	e8 bd f4 ff ff       	call   f01000a0 <_panic>
f0100be3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100be8:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100beb:	76 1e                	jbe    f0100c0b <check_page_free_list+0x238>
f0100bed:	68 3c 50 10 f0       	push   $0xf010503c
f0100bf2:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100bf7:	68 a2 02 00 00       	push   $0x2a2
f0100bfc:	68 94 4c 10 f0       	push   $0xf0104c94
f0100c01:	e8 9a f4 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c06:	83 c6 01             	add    $0x1,%esi
f0100c09:	eb 04                	jmp    f0100c0f <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c0b:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c0f:	8b 12                	mov    (%edx),%edx
f0100c11:	85 d2                	test   %edx,%edx
f0100c13:	0f 85 c8 fe ff ff    	jne    f0100ae1 <check_page_free_list+0x10e>
f0100c19:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c1c:	85 f6                	test   %esi,%esi
f0100c1e:	7f 19                	jg     f0100c39 <check_page_free_list+0x266>
f0100c20:	68 27 4d 10 f0       	push   $0xf0104d27
f0100c25:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100c2a:	68 aa 02 00 00       	push   $0x2aa
f0100c2f:	68 94 4c 10 f0       	push   $0xf0104c94
f0100c34:	e8 67 f4 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100c39:	85 db                	test   %ebx,%ebx
f0100c3b:	7f 42                	jg     f0100c7f <check_page_free_list+0x2ac>
f0100c3d:	68 39 4d 10 f0       	push   $0xf0104d39
f0100c42:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100c47:	68 ab 02 00 00       	push   $0x2ab
f0100c4c:	68 94 4c 10 f0       	push   $0xf0104c94
f0100c51:	e8 4a f4 ff ff       	call   f01000a0 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c56:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0100c5b:	85 c0                	test   %eax,%eax
f0100c5d:	0f 85 9d fd ff ff    	jne    f0100a00 <check_page_free_list+0x2d>
f0100c63:	e9 81 fd ff ff       	jmp    f01009e9 <check_page_free_list+0x16>
f0100c68:	83 3d 40 ce 17 f0 00 	cmpl   $0x0,0xf017ce40
f0100c6f:	0f 84 74 fd ff ff    	je     f01009e9 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c75:	be 00 04 00 00       	mov    $0x400,%esi
f0100c7a:	e9 cf fd ff ff       	jmp    f0100a4e <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c82:	5b                   	pop    %ebx
f0100c83:	5e                   	pop    %esi
f0100c84:	5f                   	pop    %edi
f0100c85:	5d                   	pop    %ebp
f0100c86:	c3                   	ret    

f0100c87 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c87:	55                   	push   %ebp
f0100c88:	89 e5                	mov    %esp,%ebp
f0100c8a:	57                   	push   %edi
f0100c8b:	56                   	push   %esi
f0100c8c:	53                   	push   %ebx
f0100c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
f0100c90:	c7 05 40 ce 17 f0 00 	movl   $0x0,0xf017ce40
f0100c97:	00 00 00 

	//num_alloc：在extmem区域已经被占用的页的个数
	int num_alloc = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0100c9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c9f:	e8 63 fc ff ff       	call   f0100907 <boot_alloc>
	{
	    if(i==0)
	    {
		pages[i].pp_ref = 1;
	    }    
	    else if(i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc)
f0100ca4:	8b 35 44 ce 17 f0    	mov    0xf017ce44,%esi
f0100caa:	05 00 00 00 10       	add    $0x10000000,%eax
f0100caf:	c1 e8 0c             	shr    $0xc,%eax
f0100cb2:	8d 7c 06 60          	lea    0x60(%esi,%eax,1),%edi
	//num_alloc：在extmem区域已经被占用的页的个数
	int num_alloc = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
	//num_iohole：在io hole区域占用的页数
	int num_iohole = 96;

	for(i=0; i<npages; i++)
f0100cb6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cc5:	eb 50                	jmp    f0100d17 <page_init+0x90>
	{
	    if(i==0)
f0100cc7:	85 c0                	test   %eax,%eax
f0100cc9:	75 0e                	jne    f0100cd9 <page_init+0x52>
	    {
		pages[i].pp_ref = 1;
f0100ccb:	8b 15 0c db 17 f0    	mov    0xf017db0c,%edx
f0100cd1:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
f0100cd7:	eb 3b                	jmp    f0100d14 <page_init+0x8d>
	    }    
	    else if(i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc)
f0100cd9:	39 f0                	cmp    %esi,%eax
f0100cdb:	72 13                	jb     f0100cf0 <page_init+0x69>
f0100cdd:	39 f8                	cmp    %edi,%eax
f0100cdf:	73 0f                	jae    f0100cf0 <page_init+0x69>
	    {
		pages[i].pp_ref = 1;
f0100ce1:	8b 15 0c db 17 f0    	mov    0xf017db0c,%edx
f0100ce7:	66 c7 44 c2 04 01 00 	movw   $0x1,0x4(%edx,%eax,8)
f0100cee:	eb 24                	jmp    f0100d14 <page_init+0x8d>
f0100cf0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
	    }
	    else
	    {
		pages[i].pp_ref = 0;
f0100cf7:	89 d1                	mov    %edx,%ecx
f0100cf9:	03 0d 0c db 17 f0    	add    0xf017db0c,%ecx
f0100cff:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d05:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100d07:	89 d3                	mov    %edx,%ebx
f0100d09:	03 1d 0c db 17 f0    	add    0xf017db0c,%ebx
f0100d0f:	b9 01 00 00 00       	mov    $0x1,%ecx
	//num_alloc：在extmem区域已经被占用的页的个数
	int num_alloc = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
	//num_iohole：在io hole区域占用的页数
	int num_iohole = 96;

	for(i=0; i<npages; i++)
f0100d14:	83 c0 01             	add    $0x1,%eax
f0100d17:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0100d1d:	72 a8                	jb     f0100cc7 <page_init+0x40>
f0100d1f:	84 c9                	test   %cl,%cl
f0100d21:	74 06                	je     f0100d29 <page_init+0xa2>
f0100d23:	89 1d 40 ce 17 f0    	mov    %ebx,0xf017ce40
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	    }
	}
}
f0100d29:	83 c4 0c             	add    $0xc,%esp
f0100d2c:	5b                   	pop    %ebx
f0100d2d:	5e                   	pop    %esi
f0100d2e:	5f                   	pop    %edi
f0100d2f:	5d                   	pop    %ebp
f0100d30:	c3                   	ret    

f0100d31 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d31:	55                   	push   %ebp
f0100d32:	89 e5                	mov    %esp,%ebp
f0100d34:	53                   	push   %ebx
f0100d35:	83 ec 04             	sub    $0x4,%esp
	    struct PageInfo *result;
	    if (page_free_list == NULL)
f0100d38:	8b 1d 40 ce 17 f0    	mov    0xf017ce40,%ebx
f0100d3e:	85 db                	test   %ebx,%ebx
f0100d40:	74 58                	je     f0100d9a <page_alloc+0x69>
		return NULL;

	    result= page_free_list;
	    page_free_list = result->pp_link;
f0100d42:	8b 03                	mov    (%ebx),%eax
f0100d44:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
	    result->pp_link = NULL;
f0100d49:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	    if (alloc_flags & ALLOC_ZERO)
f0100d4f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d53:	74 45                	je     f0100d9a <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d55:	89 d8                	mov    %ebx,%eax
f0100d57:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0100d5d:	c1 f8 03             	sar    $0x3,%eax
f0100d60:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d63:	89 c2                	mov    %eax,%edx
f0100d65:	c1 ea 0c             	shr    $0xc,%edx
f0100d68:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100d6e:	72 12                	jb     f0100d82 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d70:	50                   	push   %eax
f0100d71:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0100d76:	6a 56                	push   $0x56
f0100d78:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100d7d:	e8 1e f3 ff ff       	call   f01000a0 <_panic>
		memset(page2kva(result), 0, PGSIZE); 
f0100d82:	83 ec 04             	sub    $0x4,%esp
f0100d85:	68 00 10 00 00       	push   $0x1000
f0100d8a:	6a 00                	push   $0x0
f0100d8c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d91:	50                   	push   %eax
f0100d92:	e8 77 35 00 00       	call   f010430e <memset>
f0100d97:	83 c4 10             	add    $0x10,%esp

	    return result;
}
f0100d9a:	89 d8                	mov    %ebx,%eax
f0100d9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d9f:	c9                   	leave  
f0100da0:	c3                   	ret    

f0100da1 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100da1:	55                   	push   %ebp
f0100da2:	89 e5                	mov    %esp,%ebp
f0100da4:	83 ec 08             	sub    $0x8,%esp
f0100da7:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	assert(pp->pp_ref == 0);
f0100daa:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100daf:	74 19                	je     f0100dca <page_free+0x29>
f0100db1:	68 4a 4d 10 f0       	push   $0xf0104d4a
f0100db6:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100dbb:	68 57 01 00 00       	push   $0x157
f0100dc0:	68 94 4c 10 f0       	push   $0xf0104c94
f0100dc5:	e8 d6 f2 ff ff       	call   f01000a0 <_panic>
	assert(pp->pp_link == NULL);
f0100dca:	83 38 00             	cmpl   $0x0,(%eax)
f0100dcd:	74 19                	je     f0100de8 <page_free+0x47>
f0100dcf:	68 5a 4d 10 f0       	push   $0xf0104d5a
f0100dd4:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100dd9:	68 58 01 00 00       	push   $0x158
f0100dde:	68 94 4c 10 f0       	push   $0xf0104c94
f0100de3:	e8 b8 f2 ff ff       	call   f01000a0 <_panic>

	pp->pp_link = page_free_list;
f0100de8:	8b 15 40 ce 17 f0    	mov    0xf017ce40,%edx
f0100dee:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100df0:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
}
f0100df5:	c9                   	leave  
f0100df6:	c3                   	ret    

f0100df7 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100df7:	55                   	push   %ebp
f0100df8:	89 e5                	mov    %esp,%ebp
f0100dfa:	83 ec 08             	sub    $0x8,%esp
f0100dfd:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e00:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e04:	83 e8 01             	sub    $0x1,%eax
f0100e07:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e0b:	66 85 c0             	test   %ax,%ax
f0100e0e:	75 0c                	jne    f0100e1c <page_decref+0x25>
		page_free(pp);
f0100e10:	83 ec 0c             	sub    $0xc,%esp
f0100e13:	52                   	push   %edx
f0100e14:	e8 88 ff ff ff       	call   f0100da1 <page_free>
f0100e19:	83 c4 10             	add    $0x10,%esp
}
f0100e1c:	c9                   	leave  
f0100e1d:	c3                   	ret    

f0100e1e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e1e:	55                   	push   %ebp
f0100e1f:	89 e5                	mov    %esp,%ebp
f0100e21:	56                   	push   %esi
f0100e22:	53                   	push   %ebx
f0100e23:	8b 75 0c             	mov    0xc(%ebp),%esi
	unsigned int page_off;
      	pte_t * page_base = NULL;
      	struct PageInfo* new_page = NULL;
      
      	unsigned int dic_off = PDX(va);
      	pde_t * dic_entry_ptr = pgdir + dic_off;
f0100e26:	89 f3                	mov    %esi,%ebx
f0100e28:	c1 eb 16             	shr    $0x16,%ebx
f0100e2b:	c1 e3 02             	shl    $0x2,%ebx
f0100e2e:	03 5d 08             	add    0x8(%ebp),%ebx
	
	if(!(*dic_entry_ptr & PTE_P))
f0100e31:	f6 03 01             	testb  $0x1,(%ebx)
f0100e34:	75 2d                	jne    f0100e63 <pgdir_walk+0x45>
	{
		if(create)
f0100e36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e3a:	74 62                	je     f0100e9e <pgdir_walk+0x80>
      	     	 {
      	            new_page = page_alloc(1);
f0100e3c:	83 ec 0c             	sub    $0xc,%esp
f0100e3f:	6a 01                	push   $0x1
f0100e41:	e8 eb fe ff ff       	call   f0100d31 <page_alloc>
       	            if(new_page == NULL) 
f0100e46:	83 c4 10             	add    $0x10,%esp
f0100e49:	85 c0                	test   %eax,%eax
f0100e4b:	74 58                	je     f0100ea5 <pgdir_walk+0x87>
			return NULL;
                    new_page->pp_ref++;
f0100e4d:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
       	            *dic_entry_ptr = (page2pa(new_page) | PTE_P | PTE_W | PTE_U);
f0100e52:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0100e58:	c1 f8 03             	sar    $0x3,%eax
f0100e5b:	c1 e0 0c             	shl    $0xc,%eax
f0100e5e:	83 c8 07             	or     $0x7,%eax
f0100e61:	89 03                	mov    %eax,(%ebx)
		}
           	else
			return NULL;      
      	}  
   
	page_off = PTX(va);
f0100e63:	c1 ee 0c             	shr    $0xc,%esi
f0100e66:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	page_base = KADDR(PTE_ADDR(*dic_entry_ptr));
f0100e6c:	8b 03                	mov    (%ebx),%eax
f0100e6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e73:	89 c2                	mov    %eax,%edx
f0100e75:	c1 ea 0c             	shr    $0xc,%edx
f0100e78:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100e7e:	72 15                	jb     f0100e95 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e80:	50                   	push   %eax
f0100e81:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0100e86:	68 99 01 00 00       	push   $0x199
f0100e8b:	68 94 4c 10 f0       	push   $0xf0104c94
f0100e90:	e8 0b f2 ff ff       	call   f01000a0 <_panic>
	return &page_base[page_off];
f0100e95:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100e9c:	eb 0c                	jmp    f0100eaa <pgdir_walk+0x8c>
			return NULL;
                    new_page->pp_ref++;
       	            *dic_entry_ptr = (page2pa(new_page) | PTE_P | PTE_W | PTE_U);
		}
           	else
			return NULL;      
f0100e9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea3:	eb 05                	jmp    f0100eaa <pgdir_walk+0x8c>
	{
		if(create)
      	     	 {
      	            new_page = page_alloc(1);
       	            if(new_page == NULL) 
			return NULL;
f0100ea5:	b8 00 00 00 00       	mov    $0x0,%eax
      	}  
   
	page_off = PTX(va);
	page_base = KADDR(PTE_ADDR(*dic_entry_ptr));
	return &page_base[page_off];
}
f0100eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ead:	5b                   	pop    %ebx
f0100eae:	5e                   	pop    %esi
f0100eaf:	5d                   	pop    %ebp
f0100eb0:	c3                   	ret    

f0100eb1 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100eb1:	55                   	push   %ebp
f0100eb2:	89 e5                	mov    %esp,%ebp
f0100eb4:	57                   	push   %edi
f0100eb5:	56                   	push   %esi
f0100eb6:	53                   	push   %ebx
f0100eb7:	83 ec 1c             	sub    $0x1c,%esp
f0100eba:	89 c7                	mov    %eax,%edi
f0100ebc:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ebf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	int nadd;
	pte_t *entry = NULL;
	for(nadd = 0; nadd < size; nadd += PGSIZE)
f0100ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		entry = pgdir_walk(pgdir,(void *)va, 1);    //Get the table entry of this page.
		*entry = (pa | perm | PTE_P);
f0100ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100eca:	83 c8 01             	or     $0x1,%eax
f0100ecd:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	int nadd;
	pte_t *entry = NULL;
	for(nadd = 0; nadd < size; nadd += PGSIZE)
f0100ed0:	eb 1f                	jmp    f0100ef1 <boot_map_region+0x40>
	{
		entry = pgdir_walk(pgdir,(void *)va, 1);    //Get the table entry of this page.
f0100ed2:	83 ec 04             	sub    $0x4,%esp
f0100ed5:	6a 01                	push   $0x1
f0100ed7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100eda:	01 d8                	add    %ebx,%eax
f0100edc:	50                   	push   %eax
f0100edd:	57                   	push   %edi
f0100ede:	e8 3b ff ff ff       	call   f0100e1e <pgdir_walk>
		*entry = (pa | perm | PTE_P);
f0100ee3:	0b 75 dc             	or     -0x24(%ebp),%esi
f0100ee6:	89 30                	mov    %esi,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	int nadd;
	pte_t *entry = NULL;
	for(nadd = 0; nadd < size; nadd += PGSIZE)
f0100ee8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100eee:	83 c4 10             	add    $0x10,%esp
f0100ef1:	89 de                	mov    %ebx,%esi
f0100ef3:	03 75 08             	add    0x8(%ebp),%esi
f0100ef6:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0100ef9:	77 d7                	ja     f0100ed2 <boot_map_region+0x21>
		
		pa += PGSIZE;
		va += PGSIZE;
		
	}
}
f0100efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100efe:	5b                   	pop    %ebx
f0100eff:	5e                   	pop    %esi
f0100f00:	5f                   	pop    %edi
f0100f01:	5d                   	pop    %ebp
f0100f02:	c3                   	ret    

f0100f03 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f03:	55                   	push   %ebp
f0100f04:	89 e5                	mov    %esp,%ebp
f0100f06:	53                   	push   %ebx
f0100f07:	83 ec 08             	sub    $0x8,%esp
f0100f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *entry = NULL;
	struct PageInfo *ret = NULL;

	entry = pgdir_walk(pgdir, va, 0);
f0100f0d:	6a 00                	push   $0x0
f0100f0f:	ff 75 0c             	pushl  0xc(%ebp)
f0100f12:	ff 75 08             	pushl  0x8(%ebp)
f0100f15:	e8 04 ff ff ff       	call   f0100e1e <pgdir_walk>
	if(entry == NULL)
f0100f1a:	83 c4 10             	add    $0x10,%esp
f0100f1d:	85 c0                	test   %eax,%eax
f0100f1f:	74 38                	je     f0100f59 <page_lookup+0x56>
f0100f21:	89 c1                	mov    %eax,%ecx
		return NULL;
	if(!(*entry & PTE_P))
f0100f23:	8b 10                	mov    (%eax),%edx
f0100f25:	f6 c2 01             	test   $0x1,%dl
f0100f28:	74 36                	je     f0100f60 <page_lookup+0x5d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f2a:	c1 ea 0c             	shr    $0xc,%edx
f0100f2d:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100f33:	72 14                	jb     f0100f49 <page_lookup+0x46>
		panic("pa2page called with invalid pa");
f0100f35:	83 ec 04             	sub    $0x4,%esp
f0100f38:	68 84 50 10 f0       	push   $0xf0105084
f0100f3d:	6a 4f                	push   $0x4f
f0100f3f:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100f44:	e8 57 f1 ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0100f49:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
f0100f4e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        	return NULL;
    
	ret = pa2page(PTE_ADDR(*entry));
	if(pte_store != NULL)
f0100f51:	85 db                	test   %ebx,%ebx
f0100f53:	74 10                	je     f0100f65 <page_lookup+0x62>
    	{
        	*pte_store = entry;
f0100f55:	89 0b                	mov    %ecx,(%ebx)
f0100f57:	eb 0c                	jmp    f0100f65 <page_lookup+0x62>
	pte_t *entry = NULL;
	struct PageInfo *ret = NULL;

	entry = pgdir_walk(pgdir, va, 0);
	if(entry == NULL)
		return NULL;
f0100f59:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5e:	eb 05                	jmp    f0100f65 <page_lookup+0x62>
	if(!(*entry & PTE_P))
        	return NULL;
f0100f60:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte_store != NULL)
    	{
        	*pte_store = entry;
    	}
    	return ret;
}
f0100f65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f68:	c9                   	leave  
f0100f69:	c3                   	ret    

f0100f6a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f6a:	55                   	push   %ebp
f0100f6b:	89 e5                	mov    %esp,%ebp
f0100f6d:	53                   	push   %ebx
f0100f6e:	83 ec 18             	sub    $0x18,%esp
f0100f71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	 pte_t *pte = NULL;
f0100f74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f0100f7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f7e:	50                   	push   %eax
f0100f7f:	53                   	push   %ebx
f0100f80:	ff 75 08             	pushl  0x8(%ebp)
f0100f83:	e8 7b ff ff ff       	call   f0100f03 <page_lookup>
	if(page == NULL) return ;    
f0100f88:	83 c4 10             	add    $0x10,%esp
f0100f8b:	85 c0                	test   %eax,%eax
f0100f8d:	74 18                	je     f0100fa7 <page_remove+0x3d>
    
	page_decref(page);
f0100f8f:	83 ec 0c             	sub    $0xc,%esp
f0100f92:	50                   	push   %eax
f0100f93:	e8 5f fe ff ff       	call   f0100df7 <page_decref>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f98:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
	*pte = 0;
f0100f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100fa4:	83 c4 10             	add    $0x10,%esp
}
f0100fa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100faa:	c9                   	leave  
f0100fab:	c3                   	ret    

f0100fac <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fac:	55                   	push   %ebp
f0100fad:	89 e5                	mov    %esp,%ebp
f0100faf:	57                   	push   %edi
f0100fb0:	56                   	push   %esi
f0100fb1:	53                   	push   %ebx
f0100fb2:	83 ec 10             	sub    $0x10,%esp
f0100fb5:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *entry = NULL;
	entry =  pgdir_walk(pgdir, va, 1);    //Get the mapping page of this address va.
f0100fbb:	6a 01                	push   $0x1
f0100fbd:	ff 75 10             	pushl  0x10(%ebp)
f0100fc0:	56                   	push   %esi
f0100fc1:	e8 58 fe ff ff       	call   f0100e1e <pgdir_walk>
	if(entry == NULL) return -E_NO_MEM;
f0100fc6:	83 c4 10             	add    $0x10,%esp
f0100fc9:	85 c0                	test   %eax,%eax
f0100fcb:	74 4a                	je     f0101017 <page_insert+0x6b>
f0100fcd:	89 c7                	mov    %eax,%edi

	pp->pp_ref++;
f0100fcf:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if((*entry) & PTE_P)             //If this virtual address is already mapped.
f0100fd4:	f6 00 01             	testb  $0x1,(%eax)
f0100fd7:	74 15                	je     f0100fee <page_insert+0x42>
f0100fd9:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fdc:	0f 01 38             	invlpg (%eax)
	{
		tlb_invalidate(pgdir, va);
		page_remove(pgdir, va);
f0100fdf:	83 ec 08             	sub    $0x8,%esp
f0100fe2:	ff 75 10             	pushl  0x10(%ebp)
f0100fe5:	56                   	push   %esi
f0100fe6:	e8 7f ff ff ff       	call   f0100f6a <page_remove>
f0100feb:	83 c4 10             	add    $0x10,%esp
	}
	*entry = (page2pa(pp) | perm | PTE_P);
f0100fee:	2b 1d 0c db 17 f0    	sub    0xf017db0c,%ebx
f0100ff4:	c1 fb 03             	sar    $0x3,%ebx
f0100ff7:	c1 e3 0c             	shl    $0xc,%ebx
f0100ffa:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ffd:	83 c8 01             	or     $0x1,%eax
f0101000:	09 c3                	or     %eax,%ebx
f0101002:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;                  //Remember this step!
f0101004:	8b 45 10             	mov    0x10(%ebp),%eax
f0101007:	c1 e8 16             	shr    $0x16,%eax
f010100a:	8b 55 14             	mov    0x14(%ebp),%edx
f010100d:	09 14 86             	or     %edx,(%esi,%eax,4)
        
    	return 0;
f0101010:	b8 00 00 00 00       	mov    $0x0,%eax
f0101015:	eb 05                	jmp    f010101c <page_insert+0x70>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *entry = NULL;
	entry =  pgdir_walk(pgdir, va, 1);    //Get the mapping page of this address va.
	if(entry == NULL) return -E_NO_MEM;
f0101017:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
	*entry = (page2pa(pp) | perm | PTE_P);
	pgdir[PDX(va)] |= perm;                  //Remember this step!
        
    	return 0;
}
f010101c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010101f:	5b                   	pop    %ebx
f0101020:	5e                   	pop    %esi
f0101021:	5f                   	pop    %edi
f0101022:	5d                   	pop    %ebp
f0101023:	c3                   	ret    

f0101024 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101024:	55                   	push   %ebp
f0101025:	89 e5                	mov    %esp,%ebp
f0101027:	57                   	push   %edi
f0101028:	56                   	push   %esi
f0101029:	53                   	push   %ebx
f010102a:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010102d:	6a 15                	push   $0x15
f010102f:	e8 b3 1e 00 00       	call   f0102ee7 <mc146818_read>
f0101034:	89 c3                	mov    %eax,%ebx
f0101036:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010103d:	e8 a5 1e 00 00       	call   f0102ee7 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101042:	c1 e0 08             	shl    $0x8,%eax
f0101045:	09 d8                	or     %ebx,%eax
f0101047:	c1 e0 0a             	shl    $0xa,%eax
f010104a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101050:	85 c0                	test   %eax,%eax
f0101052:	0f 48 c2             	cmovs  %edx,%eax
f0101055:	c1 f8 0c             	sar    $0xc,%eax
f0101058:	a3 44 ce 17 f0       	mov    %eax,0xf017ce44
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010105d:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101064:	e8 7e 1e 00 00       	call   f0102ee7 <mc146818_read>
f0101069:	89 c3                	mov    %eax,%ebx
f010106b:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101072:	e8 70 1e 00 00       	call   f0102ee7 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101077:	c1 e0 08             	shl    $0x8,%eax
f010107a:	09 d8                	or     %ebx,%eax
f010107c:	c1 e0 0a             	shl    $0xa,%eax
f010107f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101085:	83 c4 10             	add    $0x10,%esp
f0101088:	85 c0                	test   %eax,%eax
f010108a:	0f 48 c2             	cmovs  %edx,%eax
f010108d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101090:	85 c0                	test   %eax,%eax
f0101092:	74 0e                	je     f01010a2 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101094:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010109a:	89 15 04 db 17 f0    	mov    %edx,0xf017db04
f01010a0:	eb 0c                	jmp    f01010ae <mem_init+0x8a>
	else
		npages = npages_basemem;
f01010a2:	8b 15 44 ce 17 f0    	mov    0xf017ce44,%edx
f01010a8:	89 15 04 db 17 f0    	mov    %edx,0xf017db04

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01010ae:	c1 e0 0c             	shl    $0xc,%eax
f01010b1:	c1 e8 0a             	shr    $0xa,%eax
f01010b4:	50                   	push   %eax
f01010b5:	a1 44 ce 17 f0       	mov    0xf017ce44,%eax
f01010ba:	c1 e0 0c             	shl    $0xc,%eax
f01010bd:	c1 e8 0a             	shr    $0xa,%eax
f01010c0:	50                   	push   %eax
f01010c1:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f01010c6:	c1 e0 0c             	shl    $0xc,%eax
f01010c9:	c1 e8 0a             	shr    $0xa,%eax
f01010cc:	50                   	push   %eax
f01010cd:	68 a4 50 10 f0       	push   $0xf01050a4
f01010d2:	e8 77 1e 00 00       	call   f0102f4e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01010d7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010dc:	e8 26 f8 ff ff       	call   f0100907 <boot_alloc>
f01010e1:	a3 08 db 17 f0       	mov    %eax,0xf017db08
	memset(kern_pgdir, 0, PGSIZE);
f01010e6:	83 c4 0c             	add    $0xc,%esp
f01010e9:	68 00 10 00 00       	push   $0x1000
f01010ee:	6a 00                	push   $0x0
f01010f0:	50                   	push   %eax
f01010f1:	e8 18 32 00 00       	call   f010430e <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010f6:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010fb:	83 c4 10             	add    $0x10,%esp
f01010fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101103:	77 15                	ja     f010111a <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101105:	50                   	push   %eax
f0101106:	68 e0 50 10 f0       	push   $0xf01050e0
f010110b:	68 8e 00 00 00       	push   $0x8e
f0101110:	68 94 4c 10 f0       	push   $0xf0104c94
f0101115:	e8 86 ef ff ff       	call   f01000a0 <_panic>
f010111a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101120:	83 ca 05             	or     $0x5,%edx
f0101123:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101129:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f010112e:	c1 e0 03             	shl    $0x3,%eax
f0101131:	e8 d1 f7 ff ff       	call   f0100907 <boot_alloc>
f0101136:	a3 0c db 17 f0       	mov    %eax,0xf017db0c
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010113b:	83 ec 04             	sub    $0x4,%esp
f010113e:	8b 3d 04 db 17 f0    	mov    0xf017db04,%edi
f0101144:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f010114b:	52                   	push   %edx
f010114c:	6a 00                	push   $0x0
f010114e:	50                   	push   %eax
f010114f:	e8 ba 31 00 00       	call   f010430e <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	//
	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f0101154:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101159:	e8 a9 f7 ff ff       	call   f0100907 <boot_alloc>
f010115e:	a3 4c ce 17 f0       	mov    %eax,0xf017ce4c
	memset(envs, 0, NENV * sizeof(struct Env));
f0101163:	83 c4 0c             	add    $0xc,%esp
f0101166:	68 00 80 01 00       	push   $0x18000
f010116b:	6a 00                	push   $0x0
f010116d:	50                   	push   %eax
f010116e:	e8 9b 31 00 00       	call   f010430e <memset>
	// or page_insert

	
	//
	
	page_init();
f0101173:	e8 0f fb ff ff       	call   f0100c87 <page_init>

	check_page_free_list(1);
f0101178:	b8 01 00 00 00       	mov    $0x1,%eax
f010117d:	e8 51 f8 ff ff       	call   f01009d3 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101182:	83 c4 10             	add    $0x10,%esp
f0101185:	83 3d 0c db 17 f0 00 	cmpl   $0x0,0xf017db0c
f010118c:	75 17                	jne    f01011a5 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f010118e:	83 ec 04             	sub    $0x4,%esp
f0101191:	68 6e 4d 10 f0       	push   $0xf0104d6e
f0101196:	68 bc 02 00 00       	push   $0x2bc
f010119b:	68 94 4c 10 f0       	push   $0xf0104c94
f01011a0:	e8 fb ee ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011a5:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f01011aa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011af:	eb 05                	jmp    f01011b6 <mem_init+0x192>
		++nfree;
f01011b1:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011b4:	8b 00                	mov    (%eax),%eax
f01011b6:	85 c0                	test   %eax,%eax
f01011b8:	75 f7                	jne    f01011b1 <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01011ba:	83 ec 0c             	sub    $0xc,%esp
f01011bd:	6a 00                	push   $0x0
f01011bf:	e8 6d fb ff ff       	call   f0100d31 <page_alloc>
f01011c4:	89 c7                	mov    %eax,%edi
f01011c6:	83 c4 10             	add    $0x10,%esp
f01011c9:	85 c0                	test   %eax,%eax
f01011cb:	75 19                	jne    f01011e6 <mem_init+0x1c2>
f01011cd:	68 89 4d 10 f0       	push   $0xf0104d89
f01011d2:	68 ba 4c 10 f0       	push   $0xf0104cba
f01011d7:	68 c4 02 00 00       	push   $0x2c4
f01011dc:	68 94 4c 10 f0       	push   $0xf0104c94
f01011e1:	e8 ba ee ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01011e6:	83 ec 0c             	sub    $0xc,%esp
f01011e9:	6a 00                	push   $0x0
f01011eb:	e8 41 fb ff ff       	call   f0100d31 <page_alloc>
f01011f0:	89 c6                	mov    %eax,%esi
f01011f2:	83 c4 10             	add    $0x10,%esp
f01011f5:	85 c0                	test   %eax,%eax
f01011f7:	75 19                	jne    f0101212 <mem_init+0x1ee>
f01011f9:	68 9f 4d 10 f0       	push   $0xf0104d9f
f01011fe:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101203:	68 c5 02 00 00       	push   $0x2c5
f0101208:	68 94 4c 10 f0       	push   $0xf0104c94
f010120d:	e8 8e ee ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101212:	83 ec 0c             	sub    $0xc,%esp
f0101215:	6a 00                	push   $0x0
f0101217:	e8 15 fb ff ff       	call   f0100d31 <page_alloc>
f010121c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010121f:	83 c4 10             	add    $0x10,%esp
f0101222:	85 c0                	test   %eax,%eax
f0101224:	75 19                	jne    f010123f <mem_init+0x21b>
f0101226:	68 b5 4d 10 f0       	push   $0xf0104db5
f010122b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101230:	68 c6 02 00 00       	push   $0x2c6
f0101235:	68 94 4c 10 f0       	push   $0xf0104c94
f010123a:	e8 61 ee ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010123f:	39 f7                	cmp    %esi,%edi
f0101241:	75 19                	jne    f010125c <mem_init+0x238>
f0101243:	68 cb 4d 10 f0       	push   $0xf0104dcb
f0101248:	68 ba 4c 10 f0       	push   $0xf0104cba
f010124d:	68 c9 02 00 00       	push   $0x2c9
f0101252:	68 94 4c 10 f0       	push   $0xf0104c94
f0101257:	e8 44 ee ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010125c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010125f:	39 c6                	cmp    %eax,%esi
f0101261:	74 04                	je     f0101267 <mem_init+0x243>
f0101263:	39 c7                	cmp    %eax,%edi
f0101265:	75 19                	jne    f0101280 <mem_init+0x25c>
f0101267:	68 04 51 10 f0       	push   $0xf0105104
f010126c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101271:	68 ca 02 00 00       	push   $0x2ca
f0101276:	68 94 4c 10 f0       	push   $0xf0104c94
f010127b:	e8 20 ee ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101280:	8b 0d 0c db 17 f0    	mov    0xf017db0c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101286:	8b 15 04 db 17 f0    	mov    0xf017db04,%edx
f010128c:	c1 e2 0c             	shl    $0xc,%edx
f010128f:	89 f8                	mov    %edi,%eax
f0101291:	29 c8                	sub    %ecx,%eax
f0101293:	c1 f8 03             	sar    $0x3,%eax
f0101296:	c1 e0 0c             	shl    $0xc,%eax
f0101299:	39 d0                	cmp    %edx,%eax
f010129b:	72 19                	jb     f01012b6 <mem_init+0x292>
f010129d:	68 dd 4d 10 f0       	push   $0xf0104ddd
f01012a2:	68 ba 4c 10 f0       	push   $0xf0104cba
f01012a7:	68 cb 02 00 00       	push   $0x2cb
f01012ac:	68 94 4c 10 f0       	push   $0xf0104c94
f01012b1:	e8 ea ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01012b6:	89 f0                	mov    %esi,%eax
f01012b8:	29 c8                	sub    %ecx,%eax
f01012ba:	c1 f8 03             	sar    $0x3,%eax
f01012bd:	c1 e0 0c             	shl    $0xc,%eax
f01012c0:	39 c2                	cmp    %eax,%edx
f01012c2:	77 19                	ja     f01012dd <mem_init+0x2b9>
f01012c4:	68 fa 4d 10 f0       	push   $0xf0104dfa
f01012c9:	68 ba 4c 10 f0       	push   $0xf0104cba
f01012ce:	68 cc 02 00 00       	push   $0x2cc
f01012d3:	68 94 4c 10 f0       	push   $0xf0104c94
f01012d8:	e8 c3 ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01012dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012e0:	29 c8                	sub    %ecx,%eax
f01012e2:	c1 f8 03             	sar    $0x3,%eax
f01012e5:	c1 e0 0c             	shl    $0xc,%eax
f01012e8:	39 c2                	cmp    %eax,%edx
f01012ea:	77 19                	ja     f0101305 <mem_init+0x2e1>
f01012ec:	68 17 4e 10 f0       	push   $0xf0104e17
f01012f1:	68 ba 4c 10 f0       	push   $0xf0104cba
f01012f6:	68 cd 02 00 00       	push   $0x2cd
f01012fb:	68 94 4c 10 f0       	push   $0xf0104c94
f0101300:	e8 9b ed ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101305:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f010130a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010130d:	c7 05 40 ce 17 f0 00 	movl   $0x0,0xf017ce40
f0101314:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101317:	83 ec 0c             	sub    $0xc,%esp
f010131a:	6a 00                	push   $0x0
f010131c:	e8 10 fa ff ff       	call   f0100d31 <page_alloc>
f0101321:	83 c4 10             	add    $0x10,%esp
f0101324:	85 c0                	test   %eax,%eax
f0101326:	74 19                	je     f0101341 <mem_init+0x31d>
f0101328:	68 34 4e 10 f0       	push   $0xf0104e34
f010132d:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101332:	68 d4 02 00 00       	push   $0x2d4
f0101337:	68 94 4c 10 f0       	push   $0xf0104c94
f010133c:	e8 5f ed ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101341:	83 ec 0c             	sub    $0xc,%esp
f0101344:	57                   	push   %edi
f0101345:	e8 57 fa ff ff       	call   f0100da1 <page_free>
	page_free(pp1);
f010134a:	89 34 24             	mov    %esi,(%esp)
f010134d:	e8 4f fa ff ff       	call   f0100da1 <page_free>
	page_free(pp2);
f0101352:	83 c4 04             	add    $0x4,%esp
f0101355:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101358:	e8 44 fa ff ff       	call   f0100da1 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010135d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101364:	e8 c8 f9 ff ff       	call   f0100d31 <page_alloc>
f0101369:	89 c6                	mov    %eax,%esi
f010136b:	83 c4 10             	add    $0x10,%esp
f010136e:	85 c0                	test   %eax,%eax
f0101370:	75 19                	jne    f010138b <mem_init+0x367>
f0101372:	68 89 4d 10 f0       	push   $0xf0104d89
f0101377:	68 ba 4c 10 f0       	push   $0xf0104cba
f010137c:	68 db 02 00 00       	push   $0x2db
f0101381:	68 94 4c 10 f0       	push   $0xf0104c94
f0101386:	e8 15 ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010138b:	83 ec 0c             	sub    $0xc,%esp
f010138e:	6a 00                	push   $0x0
f0101390:	e8 9c f9 ff ff       	call   f0100d31 <page_alloc>
f0101395:	89 c7                	mov    %eax,%edi
f0101397:	83 c4 10             	add    $0x10,%esp
f010139a:	85 c0                	test   %eax,%eax
f010139c:	75 19                	jne    f01013b7 <mem_init+0x393>
f010139e:	68 9f 4d 10 f0       	push   $0xf0104d9f
f01013a3:	68 ba 4c 10 f0       	push   $0xf0104cba
f01013a8:	68 dc 02 00 00       	push   $0x2dc
f01013ad:	68 94 4c 10 f0       	push   $0xf0104c94
f01013b2:	e8 e9 ec ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01013b7:	83 ec 0c             	sub    $0xc,%esp
f01013ba:	6a 00                	push   $0x0
f01013bc:	e8 70 f9 ff ff       	call   f0100d31 <page_alloc>
f01013c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013c4:	83 c4 10             	add    $0x10,%esp
f01013c7:	85 c0                	test   %eax,%eax
f01013c9:	75 19                	jne    f01013e4 <mem_init+0x3c0>
f01013cb:	68 b5 4d 10 f0       	push   $0xf0104db5
f01013d0:	68 ba 4c 10 f0       	push   $0xf0104cba
f01013d5:	68 dd 02 00 00       	push   $0x2dd
f01013da:	68 94 4c 10 f0       	push   $0xf0104c94
f01013df:	e8 bc ec ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013e4:	39 fe                	cmp    %edi,%esi
f01013e6:	75 19                	jne    f0101401 <mem_init+0x3dd>
f01013e8:	68 cb 4d 10 f0       	push   $0xf0104dcb
f01013ed:	68 ba 4c 10 f0       	push   $0xf0104cba
f01013f2:	68 df 02 00 00       	push   $0x2df
f01013f7:	68 94 4c 10 f0       	push   $0xf0104c94
f01013fc:	e8 9f ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101401:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101404:	39 c7                	cmp    %eax,%edi
f0101406:	74 04                	je     f010140c <mem_init+0x3e8>
f0101408:	39 c6                	cmp    %eax,%esi
f010140a:	75 19                	jne    f0101425 <mem_init+0x401>
f010140c:	68 04 51 10 f0       	push   $0xf0105104
f0101411:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101416:	68 e0 02 00 00       	push   $0x2e0
f010141b:	68 94 4c 10 f0       	push   $0xf0104c94
f0101420:	e8 7b ec ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101425:	83 ec 0c             	sub    $0xc,%esp
f0101428:	6a 00                	push   $0x0
f010142a:	e8 02 f9 ff ff       	call   f0100d31 <page_alloc>
f010142f:	83 c4 10             	add    $0x10,%esp
f0101432:	85 c0                	test   %eax,%eax
f0101434:	74 19                	je     f010144f <mem_init+0x42b>
f0101436:	68 34 4e 10 f0       	push   $0xf0104e34
f010143b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101440:	68 e1 02 00 00       	push   $0x2e1
f0101445:	68 94 4c 10 f0       	push   $0xf0104c94
f010144a:	e8 51 ec ff ff       	call   f01000a0 <_panic>
f010144f:	89 f0                	mov    %esi,%eax
f0101451:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101457:	c1 f8 03             	sar    $0x3,%eax
f010145a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010145d:	89 c2                	mov    %eax,%edx
f010145f:	c1 ea 0c             	shr    $0xc,%edx
f0101462:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0101468:	72 12                	jb     f010147c <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010146a:	50                   	push   %eax
f010146b:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0101470:	6a 56                	push   $0x56
f0101472:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0101477:	e8 24 ec ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010147c:	83 ec 04             	sub    $0x4,%esp
f010147f:	68 00 10 00 00       	push   $0x1000
f0101484:	6a 01                	push   $0x1
f0101486:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010148b:	50                   	push   %eax
f010148c:	e8 7d 2e 00 00       	call   f010430e <memset>
	page_free(pp0);
f0101491:	89 34 24             	mov    %esi,(%esp)
f0101494:	e8 08 f9 ff ff       	call   f0100da1 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101499:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01014a0:	e8 8c f8 ff ff       	call   f0100d31 <page_alloc>
f01014a5:	83 c4 10             	add    $0x10,%esp
f01014a8:	85 c0                	test   %eax,%eax
f01014aa:	75 19                	jne    f01014c5 <mem_init+0x4a1>
f01014ac:	68 43 4e 10 f0       	push   $0xf0104e43
f01014b1:	68 ba 4c 10 f0       	push   $0xf0104cba
f01014b6:	68 e6 02 00 00       	push   $0x2e6
f01014bb:	68 94 4c 10 f0       	push   $0xf0104c94
f01014c0:	e8 db eb ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f01014c5:	39 c6                	cmp    %eax,%esi
f01014c7:	74 19                	je     f01014e2 <mem_init+0x4be>
f01014c9:	68 61 4e 10 f0       	push   $0xf0104e61
f01014ce:	68 ba 4c 10 f0       	push   $0xf0104cba
f01014d3:	68 e7 02 00 00       	push   $0x2e7
f01014d8:	68 94 4c 10 f0       	push   $0xf0104c94
f01014dd:	e8 be eb ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014e2:	89 f0                	mov    %esi,%eax
f01014e4:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f01014ea:	c1 f8 03             	sar    $0x3,%eax
f01014ed:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014f0:	89 c2                	mov    %eax,%edx
f01014f2:	c1 ea 0c             	shr    $0xc,%edx
f01014f5:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f01014fb:	72 12                	jb     f010150f <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014fd:	50                   	push   %eax
f01014fe:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0101503:	6a 56                	push   $0x56
f0101505:	68 a0 4c 10 f0       	push   $0xf0104ca0
f010150a:	e8 91 eb ff ff       	call   f01000a0 <_panic>
f010150f:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101515:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010151b:	80 38 00             	cmpb   $0x0,(%eax)
f010151e:	74 19                	je     f0101539 <mem_init+0x515>
f0101520:	68 71 4e 10 f0       	push   $0xf0104e71
f0101525:	68 ba 4c 10 f0       	push   $0xf0104cba
f010152a:	68 ea 02 00 00       	push   $0x2ea
f010152f:	68 94 4c 10 f0       	push   $0xf0104c94
f0101534:	e8 67 eb ff ff       	call   f01000a0 <_panic>
f0101539:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010153c:	39 d0                	cmp    %edx,%eax
f010153e:	75 db                	jne    f010151b <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101540:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101543:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40

	// free the pages we took
	page_free(pp0);
f0101548:	83 ec 0c             	sub    $0xc,%esp
f010154b:	56                   	push   %esi
f010154c:	e8 50 f8 ff ff       	call   f0100da1 <page_free>
	page_free(pp1);
f0101551:	89 3c 24             	mov    %edi,(%esp)
f0101554:	e8 48 f8 ff ff       	call   f0100da1 <page_free>
	page_free(pp2);
f0101559:	83 c4 04             	add    $0x4,%esp
f010155c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010155f:	e8 3d f8 ff ff       	call   f0100da1 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101564:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0101569:	83 c4 10             	add    $0x10,%esp
f010156c:	eb 05                	jmp    f0101573 <mem_init+0x54f>
		--nfree;
f010156e:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101571:	8b 00                	mov    (%eax),%eax
f0101573:	85 c0                	test   %eax,%eax
f0101575:	75 f7                	jne    f010156e <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f0101577:	85 db                	test   %ebx,%ebx
f0101579:	74 19                	je     f0101594 <mem_init+0x570>
f010157b:	68 7b 4e 10 f0       	push   $0xf0104e7b
f0101580:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101585:	68 f7 02 00 00       	push   $0x2f7
f010158a:	68 94 4c 10 f0       	push   $0xf0104c94
f010158f:	e8 0c eb ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101594:	83 ec 0c             	sub    $0xc,%esp
f0101597:	68 24 51 10 f0       	push   $0xf0105124
f010159c:	e8 ad 19 00 00       	call   f0102f4e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a8:	e8 84 f7 ff ff       	call   f0100d31 <page_alloc>
f01015ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015b0:	83 c4 10             	add    $0x10,%esp
f01015b3:	85 c0                	test   %eax,%eax
f01015b5:	75 19                	jne    f01015d0 <mem_init+0x5ac>
f01015b7:	68 89 4d 10 f0       	push   $0xf0104d89
f01015bc:	68 ba 4c 10 f0       	push   $0xf0104cba
f01015c1:	68 55 03 00 00       	push   $0x355
f01015c6:	68 94 4c 10 f0       	push   $0xf0104c94
f01015cb:	e8 d0 ea ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01015d0:	83 ec 0c             	sub    $0xc,%esp
f01015d3:	6a 00                	push   $0x0
f01015d5:	e8 57 f7 ff ff       	call   f0100d31 <page_alloc>
f01015da:	89 c3                	mov    %eax,%ebx
f01015dc:	83 c4 10             	add    $0x10,%esp
f01015df:	85 c0                	test   %eax,%eax
f01015e1:	75 19                	jne    f01015fc <mem_init+0x5d8>
f01015e3:	68 9f 4d 10 f0       	push   $0xf0104d9f
f01015e8:	68 ba 4c 10 f0       	push   $0xf0104cba
f01015ed:	68 56 03 00 00       	push   $0x356
f01015f2:	68 94 4c 10 f0       	push   $0xf0104c94
f01015f7:	e8 a4 ea ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01015fc:	83 ec 0c             	sub    $0xc,%esp
f01015ff:	6a 00                	push   $0x0
f0101601:	e8 2b f7 ff ff       	call   f0100d31 <page_alloc>
f0101606:	89 c6                	mov    %eax,%esi
f0101608:	83 c4 10             	add    $0x10,%esp
f010160b:	85 c0                	test   %eax,%eax
f010160d:	75 19                	jne    f0101628 <mem_init+0x604>
f010160f:	68 b5 4d 10 f0       	push   $0xf0104db5
f0101614:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101619:	68 57 03 00 00       	push   $0x357
f010161e:	68 94 4c 10 f0       	push   $0xf0104c94
f0101623:	e8 78 ea ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101628:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010162b:	75 19                	jne    f0101646 <mem_init+0x622>
f010162d:	68 cb 4d 10 f0       	push   $0xf0104dcb
f0101632:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101637:	68 5a 03 00 00       	push   $0x35a
f010163c:	68 94 4c 10 f0       	push   $0xf0104c94
f0101641:	e8 5a ea ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101646:	39 c3                	cmp    %eax,%ebx
f0101648:	74 05                	je     f010164f <mem_init+0x62b>
f010164a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010164d:	75 19                	jne    f0101668 <mem_init+0x644>
f010164f:	68 04 51 10 f0       	push   $0xf0105104
f0101654:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101659:	68 5b 03 00 00       	push   $0x35b
f010165e:	68 94 4c 10 f0       	push   $0xf0104c94
f0101663:	e8 38 ea ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101668:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f010166d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101670:	c7 05 40 ce 17 f0 00 	movl   $0x0,0xf017ce40
f0101677:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010167a:	83 ec 0c             	sub    $0xc,%esp
f010167d:	6a 00                	push   $0x0
f010167f:	e8 ad f6 ff ff       	call   f0100d31 <page_alloc>
f0101684:	83 c4 10             	add    $0x10,%esp
f0101687:	85 c0                	test   %eax,%eax
f0101689:	74 19                	je     f01016a4 <mem_init+0x680>
f010168b:	68 34 4e 10 f0       	push   $0xf0104e34
f0101690:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101695:	68 62 03 00 00       	push   $0x362
f010169a:	68 94 4c 10 f0       	push   $0xf0104c94
f010169f:	e8 fc e9 ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01016a4:	83 ec 04             	sub    $0x4,%esp
f01016a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016aa:	50                   	push   %eax
f01016ab:	6a 00                	push   $0x0
f01016ad:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01016b3:	e8 4b f8 ff ff       	call   f0100f03 <page_lookup>
f01016b8:	83 c4 10             	add    $0x10,%esp
f01016bb:	85 c0                	test   %eax,%eax
f01016bd:	74 19                	je     f01016d8 <mem_init+0x6b4>
f01016bf:	68 44 51 10 f0       	push   $0xf0105144
f01016c4:	68 ba 4c 10 f0       	push   $0xf0104cba
f01016c9:	68 65 03 00 00       	push   $0x365
f01016ce:	68 94 4c 10 f0       	push   $0xf0104c94
f01016d3:	e8 c8 e9 ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016d8:	6a 02                	push   $0x2
f01016da:	6a 00                	push   $0x0
f01016dc:	53                   	push   %ebx
f01016dd:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01016e3:	e8 c4 f8 ff ff       	call   f0100fac <page_insert>
f01016e8:	83 c4 10             	add    $0x10,%esp
f01016eb:	85 c0                	test   %eax,%eax
f01016ed:	78 19                	js     f0101708 <mem_init+0x6e4>
f01016ef:	68 7c 51 10 f0       	push   $0xf010517c
f01016f4:	68 ba 4c 10 f0       	push   $0xf0104cba
f01016f9:	68 68 03 00 00       	push   $0x368
f01016fe:	68 94 4c 10 f0       	push   $0xf0104c94
f0101703:	e8 98 e9 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101708:	83 ec 0c             	sub    $0xc,%esp
f010170b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010170e:	e8 8e f6 ff ff       	call   f0100da1 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101713:	6a 02                	push   $0x2
f0101715:	6a 00                	push   $0x0
f0101717:	53                   	push   %ebx
f0101718:	ff 35 08 db 17 f0    	pushl  0xf017db08
f010171e:	e8 89 f8 ff ff       	call   f0100fac <page_insert>
f0101723:	83 c4 20             	add    $0x20,%esp
f0101726:	85 c0                	test   %eax,%eax
f0101728:	74 19                	je     f0101743 <mem_init+0x71f>
f010172a:	68 ac 51 10 f0       	push   $0xf01051ac
f010172f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101734:	68 6c 03 00 00       	push   $0x36c
f0101739:	68 94 4c 10 f0       	push   $0xf0104c94
f010173e:	e8 5d e9 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101743:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101749:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
f010174e:	89 c1                	mov    %eax,%ecx
f0101750:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101753:	8b 17                	mov    (%edi),%edx
f0101755:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010175b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010175e:	29 c8                	sub    %ecx,%eax
f0101760:	c1 f8 03             	sar    $0x3,%eax
f0101763:	c1 e0 0c             	shl    $0xc,%eax
f0101766:	39 c2                	cmp    %eax,%edx
f0101768:	74 19                	je     f0101783 <mem_init+0x75f>
f010176a:	68 dc 51 10 f0       	push   $0xf01051dc
f010176f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101774:	68 6d 03 00 00       	push   $0x36d
f0101779:	68 94 4c 10 f0       	push   $0xf0104c94
f010177e:	e8 1d e9 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101783:	ba 00 00 00 00       	mov    $0x0,%edx
f0101788:	89 f8                	mov    %edi,%eax
f010178a:	e8 e0 f1 ff ff       	call   f010096f <check_va2pa>
f010178f:	89 da                	mov    %ebx,%edx
f0101791:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101794:	c1 fa 03             	sar    $0x3,%edx
f0101797:	c1 e2 0c             	shl    $0xc,%edx
f010179a:	39 d0                	cmp    %edx,%eax
f010179c:	74 19                	je     f01017b7 <mem_init+0x793>
f010179e:	68 04 52 10 f0       	push   $0xf0105204
f01017a3:	68 ba 4c 10 f0       	push   $0xf0104cba
f01017a8:	68 6e 03 00 00       	push   $0x36e
f01017ad:	68 94 4c 10 f0       	push   $0xf0104c94
f01017b2:	e8 e9 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f01017b7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01017bc:	74 19                	je     f01017d7 <mem_init+0x7b3>
f01017be:	68 86 4e 10 f0       	push   $0xf0104e86
f01017c3:	68 ba 4c 10 f0       	push   $0xf0104cba
f01017c8:	68 6f 03 00 00       	push   $0x36f
f01017cd:	68 94 4c 10 f0       	push   $0xf0104c94
f01017d2:	e8 c9 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f01017d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017da:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01017df:	74 19                	je     f01017fa <mem_init+0x7d6>
f01017e1:	68 97 4e 10 f0       	push   $0xf0104e97
f01017e6:	68 ba 4c 10 f0       	push   $0xf0104cba
f01017eb:	68 70 03 00 00       	push   $0x370
f01017f0:	68 94 4c 10 f0       	push   $0xf0104c94
f01017f5:	e8 a6 e8 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017fa:	6a 02                	push   $0x2
f01017fc:	68 00 10 00 00       	push   $0x1000
f0101801:	56                   	push   %esi
f0101802:	57                   	push   %edi
f0101803:	e8 a4 f7 ff ff       	call   f0100fac <page_insert>
f0101808:	83 c4 10             	add    $0x10,%esp
f010180b:	85 c0                	test   %eax,%eax
f010180d:	74 19                	je     f0101828 <mem_init+0x804>
f010180f:	68 34 52 10 f0       	push   $0xf0105234
f0101814:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101819:	68 73 03 00 00       	push   $0x373
f010181e:	68 94 4c 10 f0       	push   $0xf0104c94
f0101823:	e8 78 e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101828:	ba 00 10 00 00       	mov    $0x1000,%edx
f010182d:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0101832:	e8 38 f1 ff ff       	call   f010096f <check_va2pa>
f0101837:	89 f2                	mov    %esi,%edx
f0101839:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f010183f:	c1 fa 03             	sar    $0x3,%edx
f0101842:	c1 e2 0c             	shl    $0xc,%edx
f0101845:	39 d0                	cmp    %edx,%eax
f0101847:	74 19                	je     f0101862 <mem_init+0x83e>
f0101849:	68 70 52 10 f0       	push   $0xf0105270
f010184e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101853:	68 74 03 00 00       	push   $0x374
f0101858:	68 94 4c 10 f0       	push   $0xf0104c94
f010185d:	e8 3e e8 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101862:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101867:	74 19                	je     f0101882 <mem_init+0x85e>
f0101869:	68 a8 4e 10 f0       	push   $0xf0104ea8
f010186e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101873:	68 75 03 00 00       	push   $0x375
f0101878:	68 94 4c 10 f0       	push   $0xf0104c94
f010187d:	e8 1e e8 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101882:	83 ec 0c             	sub    $0xc,%esp
f0101885:	6a 00                	push   $0x0
f0101887:	e8 a5 f4 ff ff       	call   f0100d31 <page_alloc>
f010188c:	83 c4 10             	add    $0x10,%esp
f010188f:	85 c0                	test   %eax,%eax
f0101891:	74 19                	je     f01018ac <mem_init+0x888>
f0101893:	68 34 4e 10 f0       	push   $0xf0104e34
f0101898:	68 ba 4c 10 f0       	push   $0xf0104cba
f010189d:	68 78 03 00 00       	push   $0x378
f01018a2:	68 94 4c 10 f0       	push   $0xf0104c94
f01018a7:	e8 f4 e7 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018ac:	6a 02                	push   $0x2
f01018ae:	68 00 10 00 00       	push   $0x1000
f01018b3:	56                   	push   %esi
f01018b4:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01018ba:	e8 ed f6 ff ff       	call   f0100fac <page_insert>
f01018bf:	83 c4 10             	add    $0x10,%esp
f01018c2:	85 c0                	test   %eax,%eax
f01018c4:	74 19                	je     f01018df <mem_init+0x8bb>
f01018c6:	68 34 52 10 f0       	push   $0xf0105234
f01018cb:	68 ba 4c 10 f0       	push   $0xf0104cba
f01018d0:	68 7b 03 00 00       	push   $0x37b
f01018d5:	68 94 4c 10 f0       	push   $0xf0104c94
f01018da:	e8 c1 e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018df:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018e4:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f01018e9:	e8 81 f0 ff ff       	call   f010096f <check_va2pa>
f01018ee:	89 f2                	mov    %esi,%edx
f01018f0:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f01018f6:	c1 fa 03             	sar    $0x3,%edx
f01018f9:	c1 e2 0c             	shl    $0xc,%edx
f01018fc:	39 d0                	cmp    %edx,%eax
f01018fe:	74 19                	je     f0101919 <mem_init+0x8f5>
f0101900:	68 70 52 10 f0       	push   $0xf0105270
f0101905:	68 ba 4c 10 f0       	push   $0xf0104cba
f010190a:	68 7c 03 00 00       	push   $0x37c
f010190f:	68 94 4c 10 f0       	push   $0xf0104c94
f0101914:	e8 87 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101919:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010191e:	74 19                	je     f0101939 <mem_init+0x915>
f0101920:	68 a8 4e 10 f0       	push   $0xf0104ea8
f0101925:	68 ba 4c 10 f0       	push   $0xf0104cba
f010192a:	68 7d 03 00 00       	push   $0x37d
f010192f:	68 94 4c 10 f0       	push   $0xf0104c94
f0101934:	e8 67 e7 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101939:	83 ec 0c             	sub    $0xc,%esp
f010193c:	6a 00                	push   $0x0
f010193e:	e8 ee f3 ff ff       	call   f0100d31 <page_alloc>
f0101943:	83 c4 10             	add    $0x10,%esp
f0101946:	85 c0                	test   %eax,%eax
f0101948:	74 19                	je     f0101963 <mem_init+0x93f>
f010194a:	68 34 4e 10 f0       	push   $0xf0104e34
f010194f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101954:	68 81 03 00 00       	push   $0x381
f0101959:	68 94 4c 10 f0       	push   $0xf0104c94
f010195e:	e8 3d e7 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101963:	8b 15 08 db 17 f0    	mov    0xf017db08,%edx
f0101969:	8b 02                	mov    (%edx),%eax
f010196b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101970:	89 c1                	mov    %eax,%ecx
f0101972:	c1 e9 0c             	shr    $0xc,%ecx
f0101975:	3b 0d 04 db 17 f0    	cmp    0xf017db04,%ecx
f010197b:	72 15                	jb     f0101992 <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010197d:	50                   	push   %eax
f010197e:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0101983:	68 84 03 00 00       	push   $0x384
f0101988:	68 94 4c 10 f0       	push   $0xf0104c94
f010198d:	e8 0e e7 ff ff       	call   f01000a0 <_panic>
f0101992:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101997:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010199a:	83 ec 04             	sub    $0x4,%esp
f010199d:	6a 00                	push   $0x0
f010199f:	68 00 10 00 00       	push   $0x1000
f01019a4:	52                   	push   %edx
f01019a5:	e8 74 f4 ff ff       	call   f0100e1e <pgdir_walk>
f01019aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01019ad:	8d 57 04             	lea    0x4(%edi),%edx
f01019b0:	83 c4 10             	add    $0x10,%esp
f01019b3:	39 d0                	cmp    %edx,%eax
f01019b5:	74 19                	je     f01019d0 <mem_init+0x9ac>
f01019b7:	68 a0 52 10 f0       	push   $0xf01052a0
f01019bc:	68 ba 4c 10 f0       	push   $0xf0104cba
f01019c1:	68 85 03 00 00       	push   $0x385
f01019c6:	68 94 4c 10 f0       	push   $0xf0104c94
f01019cb:	e8 d0 e6 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01019d0:	6a 06                	push   $0x6
f01019d2:	68 00 10 00 00       	push   $0x1000
f01019d7:	56                   	push   %esi
f01019d8:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01019de:	e8 c9 f5 ff ff       	call   f0100fac <page_insert>
f01019e3:	83 c4 10             	add    $0x10,%esp
f01019e6:	85 c0                	test   %eax,%eax
f01019e8:	74 19                	je     f0101a03 <mem_init+0x9df>
f01019ea:	68 e0 52 10 f0       	push   $0xf01052e0
f01019ef:	68 ba 4c 10 f0       	push   $0xf0104cba
f01019f4:	68 88 03 00 00       	push   $0x388
f01019f9:	68 94 4c 10 f0       	push   $0xf0104c94
f01019fe:	e8 9d e6 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a03:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101a09:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a0e:	89 f8                	mov    %edi,%eax
f0101a10:	e8 5a ef ff ff       	call   f010096f <check_va2pa>
f0101a15:	89 f2                	mov    %esi,%edx
f0101a17:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0101a1d:	c1 fa 03             	sar    $0x3,%edx
f0101a20:	c1 e2 0c             	shl    $0xc,%edx
f0101a23:	39 d0                	cmp    %edx,%eax
f0101a25:	74 19                	je     f0101a40 <mem_init+0xa1c>
f0101a27:	68 70 52 10 f0       	push   $0xf0105270
f0101a2c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101a31:	68 89 03 00 00       	push   $0x389
f0101a36:	68 94 4c 10 f0       	push   $0xf0104c94
f0101a3b:	e8 60 e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101a40:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a45:	74 19                	je     f0101a60 <mem_init+0xa3c>
f0101a47:	68 a8 4e 10 f0       	push   $0xf0104ea8
f0101a4c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101a51:	68 8a 03 00 00       	push   $0x38a
f0101a56:	68 94 4c 10 f0       	push   $0xf0104c94
f0101a5b:	e8 40 e6 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a60:	83 ec 04             	sub    $0x4,%esp
f0101a63:	6a 00                	push   $0x0
f0101a65:	68 00 10 00 00       	push   $0x1000
f0101a6a:	57                   	push   %edi
f0101a6b:	e8 ae f3 ff ff       	call   f0100e1e <pgdir_walk>
f0101a70:	83 c4 10             	add    $0x10,%esp
f0101a73:	f6 00 04             	testb  $0x4,(%eax)
f0101a76:	75 19                	jne    f0101a91 <mem_init+0xa6d>
f0101a78:	68 20 53 10 f0       	push   $0xf0105320
f0101a7d:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101a82:	68 8b 03 00 00       	push   $0x38b
f0101a87:	68 94 4c 10 f0       	push   $0xf0104c94
f0101a8c:	e8 0f e6 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a91:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0101a96:	f6 00 04             	testb  $0x4,(%eax)
f0101a99:	75 19                	jne    f0101ab4 <mem_init+0xa90>
f0101a9b:	68 b9 4e 10 f0       	push   $0xf0104eb9
f0101aa0:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101aa5:	68 8c 03 00 00       	push   $0x38c
f0101aaa:	68 94 4c 10 f0       	push   $0xf0104c94
f0101aaf:	e8 ec e5 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ab4:	6a 02                	push   $0x2
f0101ab6:	68 00 10 00 00       	push   $0x1000
f0101abb:	56                   	push   %esi
f0101abc:	50                   	push   %eax
f0101abd:	e8 ea f4 ff ff       	call   f0100fac <page_insert>
f0101ac2:	83 c4 10             	add    $0x10,%esp
f0101ac5:	85 c0                	test   %eax,%eax
f0101ac7:	74 19                	je     f0101ae2 <mem_init+0xabe>
f0101ac9:	68 34 52 10 f0       	push   $0xf0105234
f0101ace:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101ad3:	68 8f 03 00 00       	push   $0x38f
f0101ad8:	68 94 4c 10 f0       	push   $0xf0104c94
f0101add:	e8 be e5 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ae2:	83 ec 04             	sub    $0x4,%esp
f0101ae5:	6a 00                	push   $0x0
f0101ae7:	68 00 10 00 00       	push   $0x1000
f0101aec:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101af2:	e8 27 f3 ff ff       	call   f0100e1e <pgdir_walk>
f0101af7:	83 c4 10             	add    $0x10,%esp
f0101afa:	f6 00 02             	testb  $0x2,(%eax)
f0101afd:	75 19                	jne    f0101b18 <mem_init+0xaf4>
f0101aff:	68 54 53 10 f0       	push   $0xf0105354
f0101b04:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101b09:	68 90 03 00 00       	push   $0x390
f0101b0e:	68 94 4c 10 f0       	push   $0xf0104c94
f0101b13:	e8 88 e5 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b18:	83 ec 04             	sub    $0x4,%esp
f0101b1b:	6a 00                	push   $0x0
f0101b1d:	68 00 10 00 00       	push   $0x1000
f0101b22:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101b28:	e8 f1 f2 ff ff       	call   f0100e1e <pgdir_walk>
f0101b2d:	83 c4 10             	add    $0x10,%esp
f0101b30:	f6 00 04             	testb  $0x4,(%eax)
f0101b33:	74 19                	je     f0101b4e <mem_init+0xb2a>
f0101b35:	68 88 53 10 f0       	push   $0xf0105388
f0101b3a:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101b3f:	68 91 03 00 00       	push   $0x391
f0101b44:	68 94 4c 10 f0       	push   $0xf0104c94
f0101b49:	e8 52 e5 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b4e:	6a 02                	push   $0x2
f0101b50:	68 00 00 40 00       	push   $0x400000
f0101b55:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b58:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101b5e:	e8 49 f4 ff ff       	call   f0100fac <page_insert>
f0101b63:	83 c4 10             	add    $0x10,%esp
f0101b66:	85 c0                	test   %eax,%eax
f0101b68:	78 19                	js     f0101b83 <mem_init+0xb5f>
f0101b6a:	68 c0 53 10 f0       	push   $0xf01053c0
f0101b6f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101b74:	68 94 03 00 00       	push   $0x394
f0101b79:	68 94 4c 10 f0       	push   $0xf0104c94
f0101b7e:	e8 1d e5 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b83:	6a 02                	push   $0x2
f0101b85:	68 00 10 00 00       	push   $0x1000
f0101b8a:	53                   	push   %ebx
f0101b8b:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101b91:	e8 16 f4 ff ff       	call   f0100fac <page_insert>
f0101b96:	83 c4 10             	add    $0x10,%esp
f0101b99:	85 c0                	test   %eax,%eax
f0101b9b:	74 19                	je     f0101bb6 <mem_init+0xb92>
f0101b9d:	68 f8 53 10 f0       	push   $0xf01053f8
f0101ba2:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101ba7:	68 97 03 00 00       	push   $0x397
f0101bac:	68 94 4c 10 f0       	push   $0xf0104c94
f0101bb1:	e8 ea e4 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bb6:	83 ec 04             	sub    $0x4,%esp
f0101bb9:	6a 00                	push   $0x0
f0101bbb:	68 00 10 00 00       	push   $0x1000
f0101bc0:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101bc6:	e8 53 f2 ff ff       	call   f0100e1e <pgdir_walk>
f0101bcb:	83 c4 10             	add    $0x10,%esp
f0101bce:	f6 00 04             	testb  $0x4,(%eax)
f0101bd1:	74 19                	je     f0101bec <mem_init+0xbc8>
f0101bd3:	68 88 53 10 f0       	push   $0xf0105388
f0101bd8:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101bdd:	68 98 03 00 00       	push   $0x398
f0101be2:	68 94 4c 10 f0       	push   $0xf0104c94
f0101be7:	e8 b4 e4 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bec:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101bf2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bf7:	89 f8                	mov    %edi,%eax
f0101bf9:	e8 71 ed ff ff       	call   f010096f <check_va2pa>
f0101bfe:	89 c1                	mov    %eax,%ecx
f0101c00:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c03:	89 d8                	mov    %ebx,%eax
f0101c05:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101c0b:	c1 f8 03             	sar    $0x3,%eax
f0101c0e:	c1 e0 0c             	shl    $0xc,%eax
f0101c11:	39 c1                	cmp    %eax,%ecx
f0101c13:	74 19                	je     f0101c2e <mem_init+0xc0a>
f0101c15:	68 34 54 10 f0       	push   $0xf0105434
f0101c1a:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101c1f:	68 9b 03 00 00       	push   $0x39b
f0101c24:	68 94 4c 10 f0       	push   $0xf0104c94
f0101c29:	e8 72 e4 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c2e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c33:	89 f8                	mov    %edi,%eax
f0101c35:	e8 35 ed ff ff       	call   f010096f <check_va2pa>
f0101c3a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101c3d:	74 19                	je     f0101c58 <mem_init+0xc34>
f0101c3f:	68 60 54 10 f0       	push   $0xf0105460
f0101c44:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101c49:	68 9c 03 00 00       	push   $0x39c
f0101c4e:	68 94 4c 10 f0       	push   $0xf0104c94
f0101c53:	e8 48 e4 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c58:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c5d:	74 19                	je     f0101c78 <mem_init+0xc54>
f0101c5f:	68 cf 4e 10 f0       	push   $0xf0104ecf
f0101c64:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101c69:	68 9e 03 00 00       	push   $0x39e
f0101c6e:	68 94 4c 10 f0       	push   $0xf0104c94
f0101c73:	e8 28 e4 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101c78:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c7d:	74 19                	je     f0101c98 <mem_init+0xc74>
f0101c7f:	68 e0 4e 10 f0       	push   $0xf0104ee0
f0101c84:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101c89:	68 9f 03 00 00       	push   $0x39f
f0101c8e:	68 94 4c 10 f0       	push   $0xf0104c94
f0101c93:	e8 08 e4 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c98:	83 ec 0c             	sub    $0xc,%esp
f0101c9b:	6a 00                	push   $0x0
f0101c9d:	e8 8f f0 ff ff       	call   f0100d31 <page_alloc>
f0101ca2:	83 c4 10             	add    $0x10,%esp
f0101ca5:	85 c0                	test   %eax,%eax
f0101ca7:	74 04                	je     f0101cad <mem_init+0xc89>
f0101ca9:	39 c6                	cmp    %eax,%esi
f0101cab:	74 19                	je     f0101cc6 <mem_init+0xca2>
f0101cad:	68 90 54 10 f0       	push   $0xf0105490
f0101cb2:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101cb7:	68 a2 03 00 00       	push   $0x3a2
f0101cbc:	68 94 4c 10 f0       	push   $0xf0104c94
f0101cc1:	e8 da e3 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101cc6:	83 ec 08             	sub    $0x8,%esp
f0101cc9:	6a 00                	push   $0x0
f0101ccb:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101cd1:	e8 94 f2 ff ff       	call   f0100f6a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cd6:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101cdc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ce1:	89 f8                	mov    %edi,%eax
f0101ce3:	e8 87 ec ff ff       	call   f010096f <check_va2pa>
f0101ce8:	83 c4 10             	add    $0x10,%esp
f0101ceb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cee:	74 19                	je     f0101d09 <mem_init+0xce5>
f0101cf0:	68 b4 54 10 f0       	push   $0xf01054b4
f0101cf5:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101cfa:	68 a6 03 00 00       	push   $0x3a6
f0101cff:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d04:	e8 97 e3 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d09:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0e:	89 f8                	mov    %edi,%eax
f0101d10:	e8 5a ec ff ff       	call   f010096f <check_va2pa>
f0101d15:	89 da                	mov    %ebx,%edx
f0101d17:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0101d1d:	c1 fa 03             	sar    $0x3,%edx
f0101d20:	c1 e2 0c             	shl    $0xc,%edx
f0101d23:	39 d0                	cmp    %edx,%eax
f0101d25:	74 19                	je     f0101d40 <mem_init+0xd1c>
f0101d27:	68 60 54 10 f0       	push   $0xf0105460
f0101d2c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101d31:	68 a7 03 00 00       	push   $0x3a7
f0101d36:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d3b:	e8 60 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101d40:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d45:	74 19                	je     f0101d60 <mem_init+0xd3c>
f0101d47:	68 86 4e 10 f0       	push   $0xf0104e86
f0101d4c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101d51:	68 a8 03 00 00       	push   $0x3a8
f0101d56:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d5b:	e8 40 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101d60:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d65:	74 19                	je     f0101d80 <mem_init+0xd5c>
f0101d67:	68 e0 4e 10 f0       	push   $0xf0104ee0
f0101d6c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101d71:	68 a9 03 00 00       	push   $0x3a9
f0101d76:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d7b:	e8 20 e3 ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d80:	6a 00                	push   $0x0
f0101d82:	68 00 10 00 00       	push   $0x1000
f0101d87:	53                   	push   %ebx
f0101d88:	57                   	push   %edi
f0101d89:	e8 1e f2 ff ff       	call   f0100fac <page_insert>
f0101d8e:	83 c4 10             	add    $0x10,%esp
f0101d91:	85 c0                	test   %eax,%eax
f0101d93:	74 19                	je     f0101dae <mem_init+0xd8a>
f0101d95:	68 d8 54 10 f0       	push   $0xf01054d8
f0101d9a:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101d9f:	68 ac 03 00 00       	push   $0x3ac
f0101da4:	68 94 4c 10 f0       	push   $0xf0104c94
f0101da9:	e8 f2 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101dae:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101db3:	75 19                	jne    f0101dce <mem_init+0xdaa>
f0101db5:	68 f1 4e 10 f0       	push   $0xf0104ef1
f0101dba:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101dbf:	68 ad 03 00 00       	push   $0x3ad
f0101dc4:	68 94 4c 10 f0       	push   $0xf0104c94
f0101dc9:	e8 d2 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0101dce:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101dd1:	74 19                	je     f0101dec <mem_init+0xdc8>
f0101dd3:	68 fd 4e 10 f0       	push   $0xf0104efd
f0101dd8:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101ddd:	68 ae 03 00 00       	push   $0x3ae
f0101de2:	68 94 4c 10 f0       	push   $0xf0104c94
f0101de7:	e8 b4 e2 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101dec:	83 ec 08             	sub    $0x8,%esp
f0101def:	68 00 10 00 00       	push   $0x1000
f0101df4:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101dfa:	e8 6b f1 ff ff       	call   f0100f6a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dff:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101e05:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e0a:	89 f8                	mov    %edi,%eax
f0101e0c:	e8 5e eb ff ff       	call   f010096f <check_va2pa>
f0101e11:	83 c4 10             	add    $0x10,%esp
f0101e14:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e17:	74 19                	je     f0101e32 <mem_init+0xe0e>
f0101e19:	68 b4 54 10 f0       	push   $0xf01054b4
f0101e1e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101e23:	68 b2 03 00 00       	push   $0x3b2
f0101e28:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e2d:	e8 6e e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e32:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e37:	89 f8                	mov    %edi,%eax
f0101e39:	e8 31 eb ff ff       	call   f010096f <check_va2pa>
f0101e3e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e41:	74 19                	je     f0101e5c <mem_init+0xe38>
f0101e43:	68 10 55 10 f0       	push   $0xf0105510
f0101e48:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101e4d:	68 b3 03 00 00       	push   $0x3b3
f0101e52:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e57:	e8 44 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101e5c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e61:	74 19                	je     f0101e7c <mem_init+0xe58>
f0101e63:	68 12 4f 10 f0       	push   $0xf0104f12
f0101e68:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101e6d:	68 b4 03 00 00       	push   $0x3b4
f0101e72:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e77:	e8 24 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101e7c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e81:	74 19                	je     f0101e9c <mem_init+0xe78>
f0101e83:	68 e0 4e 10 f0       	push   $0xf0104ee0
f0101e88:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101e8d:	68 b5 03 00 00       	push   $0x3b5
f0101e92:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e97:	e8 04 e2 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e9c:	83 ec 0c             	sub    $0xc,%esp
f0101e9f:	6a 00                	push   $0x0
f0101ea1:	e8 8b ee ff ff       	call   f0100d31 <page_alloc>
f0101ea6:	83 c4 10             	add    $0x10,%esp
f0101ea9:	39 c3                	cmp    %eax,%ebx
f0101eab:	75 04                	jne    f0101eb1 <mem_init+0xe8d>
f0101ead:	85 c0                	test   %eax,%eax
f0101eaf:	75 19                	jne    f0101eca <mem_init+0xea6>
f0101eb1:	68 38 55 10 f0       	push   $0xf0105538
f0101eb6:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101ebb:	68 b8 03 00 00       	push   $0x3b8
f0101ec0:	68 94 4c 10 f0       	push   $0xf0104c94
f0101ec5:	e8 d6 e1 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101eca:	83 ec 0c             	sub    $0xc,%esp
f0101ecd:	6a 00                	push   $0x0
f0101ecf:	e8 5d ee ff ff       	call   f0100d31 <page_alloc>
f0101ed4:	83 c4 10             	add    $0x10,%esp
f0101ed7:	85 c0                	test   %eax,%eax
f0101ed9:	74 19                	je     f0101ef4 <mem_init+0xed0>
f0101edb:	68 34 4e 10 f0       	push   $0xf0104e34
f0101ee0:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101ee5:	68 bb 03 00 00       	push   $0x3bb
f0101eea:	68 94 4c 10 f0       	push   $0xf0104c94
f0101eef:	e8 ac e1 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ef4:	8b 0d 08 db 17 f0    	mov    0xf017db08,%ecx
f0101efa:	8b 11                	mov    (%ecx),%edx
f0101efc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f05:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101f0b:	c1 f8 03             	sar    $0x3,%eax
f0101f0e:	c1 e0 0c             	shl    $0xc,%eax
f0101f11:	39 c2                	cmp    %eax,%edx
f0101f13:	74 19                	je     f0101f2e <mem_init+0xf0a>
f0101f15:	68 dc 51 10 f0       	push   $0xf01051dc
f0101f1a:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101f1f:	68 be 03 00 00       	push   $0x3be
f0101f24:	68 94 4c 10 f0       	push   $0xf0104c94
f0101f29:	e8 72 e1 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0101f2e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f34:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f37:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f3c:	74 19                	je     f0101f57 <mem_init+0xf33>
f0101f3e:	68 97 4e 10 f0       	push   $0xf0104e97
f0101f43:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101f48:	68 c0 03 00 00       	push   $0x3c0
f0101f4d:	68 94 4c 10 f0       	push   $0xf0104c94
f0101f52:	e8 49 e1 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0101f57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f5a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f60:	83 ec 0c             	sub    $0xc,%esp
f0101f63:	50                   	push   %eax
f0101f64:	e8 38 ee ff ff       	call   f0100da1 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f69:	83 c4 0c             	add    $0xc,%esp
f0101f6c:	6a 01                	push   $0x1
f0101f6e:	68 00 10 40 00       	push   $0x401000
f0101f73:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101f79:	e8 a0 ee ff ff       	call   f0100e1e <pgdir_walk>
f0101f7e:	89 c7                	mov    %eax,%edi
f0101f80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f83:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0101f88:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f8b:	8b 40 04             	mov    0x4(%eax),%eax
f0101f8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f93:	8b 0d 04 db 17 f0    	mov    0xf017db04,%ecx
f0101f99:	89 c2                	mov    %eax,%edx
f0101f9b:	c1 ea 0c             	shr    $0xc,%edx
f0101f9e:	83 c4 10             	add    $0x10,%esp
f0101fa1:	39 ca                	cmp    %ecx,%edx
f0101fa3:	72 15                	jb     f0101fba <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fa5:	50                   	push   %eax
f0101fa6:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0101fab:	68 c7 03 00 00       	push   $0x3c7
f0101fb0:	68 94 4c 10 f0       	push   $0xf0104c94
f0101fb5:	e8 e6 e0 ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101fba:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101fbf:	39 c7                	cmp    %eax,%edi
f0101fc1:	74 19                	je     f0101fdc <mem_init+0xfb8>
f0101fc3:	68 23 4f 10 f0       	push   $0xf0104f23
f0101fc8:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101fcd:	68 c8 03 00 00       	push   $0x3c8
f0101fd2:	68 94 4c 10 f0       	push   $0xf0104c94
f0101fd7:	e8 c4 e0 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101fdc:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101fdf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101fe6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fef:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101ff5:	c1 f8 03             	sar    $0x3,%eax
f0101ff8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ffb:	89 c2                	mov    %eax,%edx
f0101ffd:	c1 ea 0c             	shr    $0xc,%edx
f0102000:	39 d1                	cmp    %edx,%ecx
f0102002:	77 12                	ja     f0102016 <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102004:	50                   	push   %eax
f0102005:	68 9c 4f 10 f0       	push   $0xf0104f9c
f010200a:	6a 56                	push   $0x56
f010200c:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102011:	e8 8a e0 ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102016:	83 ec 04             	sub    $0x4,%esp
f0102019:	68 00 10 00 00       	push   $0x1000
f010201e:	68 ff 00 00 00       	push   $0xff
f0102023:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102028:	50                   	push   %eax
f0102029:	e8 e0 22 00 00       	call   f010430e <memset>
	page_free(pp0);
f010202e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102031:	89 3c 24             	mov    %edi,(%esp)
f0102034:	e8 68 ed ff ff       	call   f0100da1 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102039:	83 c4 0c             	add    $0xc,%esp
f010203c:	6a 01                	push   $0x1
f010203e:	6a 00                	push   $0x0
f0102040:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0102046:	e8 d3 ed ff ff       	call   f0100e1e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010204b:	89 fa                	mov    %edi,%edx
f010204d:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0102053:	c1 fa 03             	sar    $0x3,%edx
f0102056:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102059:	89 d0                	mov    %edx,%eax
f010205b:	c1 e8 0c             	shr    $0xc,%eax
f010205e:	83 c4 10             	add    $0x10,%esp
f0102061:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102067:	72 12                	jb     f010207b <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102069:	52                   	push   %edx
f010206a:	68 9c 4f 10 f0       	push   $0xf0104f9c
f010206f:	6a 56                	push   $0x56
f0102071:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102076:	e8 25 e0 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f010207b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102081:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102084:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010208a:	f6 00 01             	testb  $0x1,(%eax)
f010208d:	74 19                	je     f01020a8 <mem_init+0x1084>
f010208f:	68 3b 4f 10 f0       	push   $0xf0104f3b
f0102094:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102099:	68 d2 03 00 00       	push   $0x3d2
f010209e:	68 94 4c 10 f0       	push   $0xf0104c94
f01020a3:	e8 f8 df ff ff       	call   f01000a0 <_panic>
f01020a8:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01020ab:	39 c2                	cmp    %eax,%edx
f01020ad:	75 db                	jne    f010208a <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01020af:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f01020b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01020ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020bd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01020c3:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01020c6:	89 3d 40 ce 17 f0    	mov    %edi,0xf017ce40

	// free the pages we took
	page_free(pp0);
f01020cc:	83 ec 0c             	sub    $0xc,%esp
f01020cf:	50                   	push   %eax
f01020d0:	e8 cc ec ff ff       	call   f0100da1 <page_free>
	page_free(pp1);
f01020d5:	89 1c 24             	mov    %ebx,(%esp)
f01020d8:	e8 c4 ec ff ff       	call   f0100da1 <page_free>
	page_free(pp2);
f01020dd:	89 34 24             	mov    %esi,(%esp)
f01020e0:	e8 bc ec ff ff       	call   f0100da1 <page_free>

	cprintf("check_page() succeeded!\n");
f01020e5:	c7 04 24 52 4f 10 f0 	movl   $0xf0104f52,(%esp)
f01020ec:	e8 5d 0e 00 00       	call   f0102f4e <cprintf>

	check_page_free_list(1);
	check_page_alloc();
	check_page();
	//
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01020f1:	a1 4c ce 17 f0       	mov    0xf017ce4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020f6:	83 c4 10             	add    $0x10,%esp
f01020f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020fe:	77 15                	ja     f0102115 <mem_init+0x10f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102100:	50                   	push   %eax
f0102101:	68 e0 50 10 f0       	push   $0xf01050e0
f0102106:	68 b1 00 00 00       	push   $0xb1
f010210b:	68 94 4c 10 f0       	push   $0xf0104c94
f0102110:	e8 8b df ff ff       	call   f01000a0 <_panic>
f0102115:	83 ec 08             	sub    $0x8,%esp
f0102118:	6a 04                	push   $0x4
f010211a:	05 00 00 00 10       	add    $0x10000000,%eax
f010211f:	50                   	push   %eax
f0102120:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102125:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010212a:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f010212f:	e8 7d ed ff ff       	call   f0100eb1 <boot_map_region>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102134:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102139:	83 c4 10             	add    $0x10,%esp
f010213c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102141:	77 15                	ja     f0102158 <mem_init+0x1134>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102143:	50                   	push   %eax
f0102144:	68 e0 50 10 f0       	push   $0xf01050e0
f0102149:	68 be 00 00 00       	push   $0xbe
f010214e:	68 94 4c 10 f0       	push   $0xf0104c94
f0102153:	e8 48 df ff ff       	call   f01000a0 <_panic>
f0102158:	83 ec 08             	sub    $0x8,%esp
f010215b:	6a 04                	push   $0x4
f010215d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102162:	50                   	push   %eax
f0102163:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102168:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010216d:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0102172:	e8 3a ed ff ff       	call   f0100eb1 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102177:	83 c4 10             	add    $0x10,%esp
f010217a:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f010217f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102184:	77 15                	ja     f010219b <mem_init+0x1177>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102186:	50                   	push   %eax
f0102187:	68 e0 50 10 f0       	push   $0xf01050e0
f010218c:	68 d2 00 00 00       	push   $0xd2
f0102191:	68 94 4c 10 f0       	push   $0xf0104c94
f0102196:	e8 05 df ff ff       	call   f01000a0 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010219b:	83 ec 08             	sub    $0x8,%esp
f010219e:	6a 02                	push   $0x2
f01021a0:	68 00 10 11 00       	push   $0x111000
f01021a5:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021aa:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021af:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f01021b4:	e8 f8 ec ff ff       	call   f0100eb1 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f01021b9:	83 c4 08             	add    $0x8,%esp
f01021bc:	6a 02                	push   $0x2
f01021be:	6a 00                	push   $0x0
f01021c0:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01021c5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021ca:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f01021cf:	e8 dd ec ff ff       	call   f0100eb1 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01021d4:	8b 1d 08 db 17 f0    	mov    0xf017db08,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021da:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f01021df:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021e2:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021f1:	8b 3d 0c db 17 f0    	mov    0xf017db0c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021f7:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01021fa:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021fd:	be 00 00 00 00       	mov    $0x0,%esi
f0102202:	eb 55                	jmp    f0102259 <mem_init+0x1235>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102204:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f010220a:	89 d8                	mov    %ebx,%eax
f010220c:	e8 5e e7 ff ff       	call   f010096f <check_va2pa>
f0102211:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102218:	77 15                	ja     f010222f <mem_init+0x120b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010221a:	57                   	push   %edi
f010221b:	68 e0 50 10 f0       	push   $0xf01050e0
f0102220:	68 0f 03 00 00       	push   $0x30f
f0102225:	68 94 4c 10 f0       	push   $0xf0104c94
f010222a:	e8 71 de ff ff       	call   f01000a0 <_panic>
f010222f:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f0102236:	39 d0                	cmp    %edx,%eax
f0102238:	74 19                	je     f0102253 <mem_init+0x122f>
f010223a:	68 5c 55 10 f0       	push   $0xf010555c
f010223f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102244:	68 0f 03 00 00       	push   $0x30f
f0102249:	68 94 4c 10 f0       	push   $0xf0104c94
f010224e:	e8 4d de ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102253:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102259:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010225c:	77 a6                	ja     f0102204 <mem_init+0x11e0>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010225e:	8b 3d 4c ce 17 f0    	mov    0xf017ce4c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102264:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102267:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f010226c:	89 f2                	mov    %esi,%edx
f010226e:	89 d8                	mov    %ebx,%eax
f0102270:	e8 fa e6 ff ff       	call   f010096f <check_va2pa>
f0102275:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010227c:	77 15                	ja     f0102293 <mem_init+0x126f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010227e:	57                   	push   %edi
f010227f:	68 e0 50 10 f0       	push   $0xf01050e0
f0102284:	68 14 03 00 00       	push   $0x314
f0102289:	68 94 4c 10 f0       	push   $0xf0104c94
f010228e:	e8 0d de ff ff       	call   f01000a0 <_panic>
f0102293:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f010229a:	39 c2                	cmp    %eax,%edx
f010229c:	74 19                	je     f01022b7 <mem_init+0x1293>
f010229e:	68 90 55 10 f0       	push   $0xf0105590
f01022a3:	68 ba 4c 10 f0       	push   $0xf0104cba
f01022a8:	68 14 03 00 00       	push   $0x314
f01022ad:	68 94 4c 10 f0       	push   $0xf0104c94
f01022b2:	e8 e9 dd ff ff       	call   f01000a0 <_panic>
f01022b7:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022bd:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f01022c3:	75 a7                	jne    f010226c <mem_init+0x1248>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022c5:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01022c8:	c1 e7 0c             	shl    $0xc,%edi
f01022cb:	be 00 00 00 00       	mov    $0x0,%esi
f01022d0:	eb 30                	jmp    f0102302 <mem_init+0x12de>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01022d2:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01022d8:	89 d8                	mov    %ebx,%eax
f01022da:	e8 90 e6 ff ff       	call   f010096f <check_va2pa>
f01022df:	39 c6                	cmp    %eax,%esi
f01022e1:	74 19                	je     f01022fc <mem_init+0x12d8>
f01022e3:	68 c4 55 10 f0       	push   $0xf01055c4
f01022e8:	68 ba 4c 10 f0       	push   $0xf0104cba
f01022ed:	68 18 03 00 00       	push   $0x318
f01022f2:	68 94 4c 10 f0       	push   $0xf0104c94
f01022f7:	e8 a4 dd ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022fc:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102302:	39 fe                	cmp    %edi,%esi
f0102304:	72 cc                	jb     f01022d2 <mem_init+0x12ae>
f0102306:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010230b:	89 f2                	mov    %esi,%edx
f010230d:	89 d8                	mov    %ebx,%eax
f010230f:	e8 5b e6 ff ff       	call   f010096f <check_va2pa>
f0102314:	8d 96 00 90 11 10    	lea    0x10119000(%esi),%edx
f010231a:	39 c2                	cmp    %eax,%edx
f010231c:	74 19                	je     f0102337 <mem_init+0x1313>
f010231e:	68 ec 55 10 f0       	push   $0xf01055ec
f0102323:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102328:	68 1c 03 00 00       	push   $0x31c
f010232d:	68 94 4c 10 f0       	push   $0xf0104c94
f0102332:	e8 69 dd ff ff       	call   f01000a0 <_panic>
f0102337:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010233d:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102343:	75 c6                	jne    f010230b <mem_init+0x12e7>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102345:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010234a:	89 d8                	mov    %ebx,%eax
f010234c:	e8 1e e6 ff ff       	call   f010096f <check_va2pa>
f0102351:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102354:	74 51                	je     f01023a7 <mem_init+0x1383>
f0102356:	68 34 56 10 f0       	push   $0xf0105634
f010235b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102360:	68 1d 03 00 00       	push   $0x31d
f0102365:	68 94 4c 10 f0       	push   $0xf0104c94
f010236a:	e8 31 dd ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010236f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102374:	72 36                	jb     f01023ac <mem_init+0x1388>
f0102376:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010237b:	76 07                	jbe    f0102384 <mem_init+0x1360>
f010237d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102382:	75 28                	jne    f01023ac <mem_init+0x1388>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102384:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102388:	0f 85 83 00 00 00    	jne    f0102411 <mem_init+0x13ed>
f010238e:	68 6b 4f 10 f0       	push   $0xf0104f6b
f0102393:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102398:	68 26 03 00 00       	push   $0x326
f010239d:	68 94 4c 10 f0       	push   $0xf0104c94
f01023a2:	e8 f9 dc ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023a7:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01023ac:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023b1:	76 3f                	jbe    f01023f2 <mem_init+0x13ce>
				assert(pgdir[i] & PTE_P);
f01023b3:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01023b6:	f6 c2 01             	test   $0x1,%dl
f01023b9:	75 19                	jne    f01023d4 <mem_init+0x13b0>
f01023bb:	68 6b 4f 10 f0       	push   $0xf0104f6b
f01023c0:	68 ba 4c 10 f0       	push   $0xf0104cba
f01023c5:	68 2a 03 00 00       	push   $0x32a
f01023ca:	68 94 4c 10 f0       	push   $0xf0104c94
f01023cf:	e8 cc dc ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f01023d4:	f6 c2 02             	test   $0x2,%dl
f01023d7:	75 38                	jne    f0102411 <mem_init+0x13ed>
f01023d9:	68 7c 4f 10 f0       	push   $0xf0104f7c
f01023de:	68 ba 4c 10 f0       	push   $0xf0104cba
f01023e3:	68 2b 03 00 00       	push   $0x32b
f01023e8:	68 94 4c 10 f0       	push   $0xf0104c94
f01023ed:	e8 ae dc ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f01023f2:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01023f6:	74 19                	je     f0102411 <mem_init+0x13ed>
f01023f8:	68 8d 4f 10 f0       	push   $0xf0104f8d
f01023fd:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102402:	68 2d 03 00 00       	push   $0x32d
f0102407:	68 94 4c 10 f0       	push   $0xf0104c94
f010240c:	e8 8f dc ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102411:	83 c0 01             	add    $0x1,%eax
f0102414:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102419:	0f 86 50 ff ff ff    	jbe    f010236f <mem_init+0x134b>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010241f:	83 ec 0c             	sub    $0xc,%esp
f0102422:	68 64 56 10 f0       	push   $0xf0105664
f0102427:	e8 22 0b 00 00       	call   f0102f4e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010242c:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102431:	83 c4 10             	add    $0x10,%esp
f0102434:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102439:	77 15                	ja     f0102450 <mem_init+0x142c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010243b:	50                   	push   %eax
f010243c:	68 e0 50 10 f0       	push   $0xf01050e0
f0102441:	68 e6 00 00 00       	push   $0xe6
f0102446:	68 94 4c 10 f0       	push   $0xf0104c94
f010244b:	e8 50 dc ff ff       	call   f01000a0 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102450:	05 00 00 00 10       	add    $0x10000000,%eax
f0102455:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102458:	b8 00 00 00 00       	mov    $0x0,%eax
f010245d:	e8 71 e5 ff ff       	call   f01009d3 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102462:	0f 20 c0             	mov    %cr0,%eax
f0102465:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102468:	0d 23 00 05 80       	or     $0x80050023,%eax
f010246d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102470:	83 ec 0c             	sub    $0xc,%esp
f0102473:	6a 00                	push   $0x0
f0102475:	e8 b7 e8 ff ff       	call   f0100d31 <page_alloc>
f010247a:	89 c3                	mov    %eax,%ebx
f010247c:	83 c4 10             	add    $0x10,%esp
f010247f:	85 c0                	test   %eax,%eax
f0102481:	75 19                	jne    f010249c <mem_init+0x1478>
f0102483:	68 89 4d 10 f0       	push   $0xf0104d89
f0102488:	68 ba 4c 10 f0       	push   $0xf0104cba
f010248d:	68 ed 03 00 00       	push   $0x3ed
f0102492:	68 94 4c 10 f0       	push   $0xf0104c94
f0102497:	e8 04 dc ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010249c:	83 ec 0c             	sub    $0xc,%esp
f010249f:	6a 00                	push   $0x0
f01024a1:	e8 8b e8 ff ff       	call   f0100d31 <page_alloc>
f01024a6:	89 c7                	mov    %eax,%edi
f01024a8:	83 c4 10             	add    $0x10,%esp
f01024ab:	85 c0                	test   %eax,%eax
f01024ad:	75 19                	jne    f01024c8 <mem_init+0x14a4>
f01024af:	68 9f 4d 10 f0       	push   $0xf0104d9f
f01024b4:	68 ba 4c 10 f0       	push   $0xf0104cba
f01024b9:	68 ee 03 00 00       	push   $0x3ee
f01024be:	68 94 4c 10 f0       	push   $0xf0104c94
f01024c3:	e8 d8 db ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01024c8:	83 ec 0c             	sub    $0xc,%esp
f01024cb:	6a 00                	push   $0x0
f01024cd:	e8 5f e8 ff ff       	call   f0100d31 <page_alloc>
f01024d2:	89 c6                	mov    %eax,%esi
f01024d4:	83 c4 10             	add    $0x10,%esp
f01024d7:	85 c0                	test   %eax,%eax
f01024d9:	75 19                	jne    f01024f4 <mem_init+0x14d0>
f01024db:	68 b5 4d 10 f0       	push   $0xf0104db5
f01024e0:	68 ba 4c 10 f0       	push   $0xf0104cba
f01024e5:	68 ef 03 00 00       	push   $0x3ef
f01024ea:	68 94 4c 10 f0       	push   $0xf0104c94
f01024ef:	e8 ac db ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f01024f4:	83 ec 0c             	sub    $0xc,%esp
f01024f7:	53                   	push   %ebx
f01024f8:	e8 a4 e8 ff ff       	call   f0100da1 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024fd:	89 f8                	mov    %edi,%eax
f01024ff:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0102505:	c1 f8 03             	sar    $0x3,%eax
f0102508:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010250b:	89 c2                	mov    %eax,%edx
f010250d:	c1 ea 0c             	shr    $0xc,%edx
f0102510:	83 c4 10             	add    $0x10,%esp
f0102513:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0102519:	72 12                	jb     f010252d <mem_init+0x1509>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010251b:	50                   	push   %eax
f010251c:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0102521:	6a 56                	push   $0x56
f0102523:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102528:	e8 73 db ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010252d:	83 ec 04             	sub    $0x4,%esp
f0102530:	68 00 10 00 00       	push   $0x1000
f0102535:	6a 01                	push   $0x1
f0102537:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010253c:	50                   	push   %eax
f010253d:	e8 cc 1d 00 00       	call   f010430e <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102542:	89 f0                	mov    %esi,%eax
f0102544:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f010254a:	c1 f8 03             	sar    $0x3,%eax
f010254d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102550:	89 c2                	mov    %eax,%edx
f0102552:	c1 ea 0c             	shr    $0xc,%edx
f0102555:	83 c4 10             	add    $0x10,%esp
f0102558:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f010255e:	72 12                	jb     f0102572 <mem_init+0x154e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102560:	50                   	push   %eax
f0102561:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0102566:	6a 56                	push   $0x56
f0102568:	68 a0 4c 10 f0       	push   $0xf0104ca0
f010256d:	e8 2e db ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102572:	83 ec 04             	sub    $0x4,%esp
f0102575:	68 00 10 00 00       	push   $0x1000
f010257a:	6a 02                	push   $0x2
f010257c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102581:	50                   	push   %eax
f0102582:	e8 87 1d 00 00       	call   f010430e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102587:	6a 02                	push   $0x2
f0102589:	68 00 10 00 00       	push   $0x1000
f010258e:	57                   	push   %edi
f010258f:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0102595:	e8 12 ea ff ff       	call   f0100fac <page_insert>
	assert(pp1->pp_ref == 1);
f010259a:	83 c4 20             	add    $0x20,%esp
f010259d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025a2:	74 19                	je     f01025bd <mem_init+0x1599>
f01025a4:	68 86 4e 10 f0       	push   $0xf0104e86
f01025a9:	68 ba 4c 10 f0       	push   $0xf0104cba
f01025ae:	68 f4 03 00 00       	push   $0x3f4
f01025b3:	68 94 4c 10 f0       	push   $0xf0104c94
f01025b8:	e8 e3 da ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01025bd:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01025c4:	01 01 01 
f01025c7:	74 19                	je     f01025e2 <mem_init+0x15be>
f01025c9:	68 84 56 10 f0       	push   $0xf0105684
f01025ce:	68 ba 4c 10 f0       	push   $0xf0104cba
f01025d3:	68 f5 03 00 00       	push   $0x3f5
f01025d8:	68 94 4c 10 f0       	push   $0xf0104c94
f01025dd:	e8 be da ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01025e2:	6a 02                	push   $0x2
f01025e4:	68 00 10 00 00       	push   $0x1000
f01025e9:	56                   	push   %esi
f01025ea:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01025f0:	e8 b7 e9 ff ff       	call   f0100fac <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025f5:	83 c4 10             	add    $0x10,%esp
f01025f8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025ff:	02 02 02 
f0102602:	74 19                	je     f010261d <mem_init+0x15f9>
f0102604:	68 a8 56 10 f0       	push   $0xf01056a8
f0102609:	68 ba 4c 10 f0       	push   $0xf0104cba
f010260e:	68 f7 03 00 00       	push   $0x3f7
f0102613:	68 94 4c 10 f0       	push   $0xf0104c94
f0102618:	e8 83 da ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f010261d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102622:	74 19                	je     f010263d <mem_init+0x1619>
f0102624:	68 a8 4e 10 f0       	push   $0xf0104ea8
f0102629:	68 ba 4c 10 f0       	push   $0xf0104cba
f010262e:	68 f8 03 00 00       	push   $0x3f8
f0102633:	68 94 4c 10 f0       	push   $0xf0104c94
f0102638:	e8 63 da ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f010263d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102642:	74 19                	je     f010265d <mem_init+0x1639>
f0102644:	68 12 4f 10 f0       	push   $0xf0104f12
f0102649:	68 ba 4c 10 f0       	push   $0xf0104cba
f010264e:	68 f9 03 00 00       	push   $0x3f9
f0102653:	68 94 4c 10 f0       	push   $0xf0104c94
f0102658:	e8 43 da ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010265d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102664:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102667:	89 f0                	mov    %esi,%eax
f0102669:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f010266f:	c1 f8 03             	sar    $0x3,%eax
f0102672:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102675:	89 c2                	mov    %eax,%edx
f0102677:	c1 ea 0c             	shr    $0xc,%edx
f010267a:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0102680:	72 12                	jb     f0102694 <mem_init+0x1670>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102682:	50                   	push   %eax
f0102683:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0102688:	6a 56                	push   $0x56
f010268a:	68 a0 4c 10 f0       	push   $0xf0104ca0
f010268f:	e8 0c da ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102694:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010269b:	03 03 03 
f010269e:	74 19                	je     f01026b9 <mem_init+0x1695>
f01026a0:	68 cc 56 10 f0       	push   $0xf01056cc
f01026a5:	68 ba 4c 10 f0       	push   $0xf0104cba
f01026aa:	68 fb 03 00 00       	push   $0x3fb
f01026af:	68 94 4c 10 f0       	push   $0xf0104c94
f01026b4:	e8 e7 d9 ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026b9:	83 ec 08             	sub    $0x8,%esp
f01026bc:	68 00 10 00 00       	push   $0x1000
f01026c1:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01026c7:	e8 9e e8 ff ff       	call   f0100f6a <page_remove>
	assert(pp2->pp_ref == 0);
f01026cc:	83 c4 10             	add    $0x10,%esp
f01026cf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026d4:	74 19                	je     f01026ef <mem_init+0x16cb>
f01026d6:	68 e0 4e 10 f0       	push   $0xf0104ee0
f01026db:	68 ba 4c 10 f0       	push   $0xf0104cba
f01026e0:	68 fd 03 00 00       	push   $0x3fd
f01026e5:	68 94 4c 10 f0       	push   $0xf0104c94
f01026ea:	e8 b1 d9 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026ef:	8b 0d 08 db 17 f0    	mov    0xf017db08,%ecx
f01026f5:	8b 11                	mov    (%ecx),%edx
f01026f7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026fd:	89 d8                	mov    %ebx,%eax
f01026ff:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0102705:	c1 f8 03             	sar    $0x3,%eax
f0102708:	c1 e0 0c             	shl    $0xc,%eax
f010270b:	39 c2                	cmp    %eax,%edx
f010270d:	74 19                	je     f0102728 <mem_init+0x1704>
f010270f:	68 dc 51 10 f0       	push   $0xf01051dc
f0102714:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102719:	68 00 04 00 00       	push   $0x400
f010271e:	68 94 4c 10 f0       	push   $0xf0104c94
f0102723:	e8 78 d9 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0102728:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010272e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102733:	74 19                	je     f010274e <mem_init+0x172a>
f0102735:	68 97 4e 10 f0       	push   $0xf0104e97
f010273a:	68 ba 4c 10 f0       	push   $0xf0104cba
f010273f:	68 02 04 00 00       	push   $0x402
f0102744:	68 94 4c 10 f0       	push   $0xf0104c94
f0102749:	e8 52 d9 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f010274e:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102754:	83 ec 0c             	sub    $0xc,%esp
f0102757:	53                   	push   %ebx
f0102758:	e8 44 e6 ff ff       	call   f0100da1 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010275d:	c7 04 24 f8 56 10 f0 	movl   $0xf01056f8,(%esp)
f0102764:	e8 e5 07 00 00       	call   f0102f4e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102769:	83 c4 10             	add    $0x10,%esp
f010276c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010276f:	5b                   	pop    %ebx
f0102770:	5e                   	pop    %esi
f0102771:	5f                   	pop    %edi
f0102772:	5d                   	pop    %ebp
f0102773:	c3                   	ret    

f0102774 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102774:	55                   	push   %ebp
f0102775:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102777:	8b 45 0c             	mov    0xc(%ebp),%eax
f010277a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010277d:	5d                   	pop    %ebp
f010277e:	c3                   	ret    

f010277f <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010277f:	55                   	push   %ebp
f0102780:	89 e5                	mov    %esp,%ebp
f0102782:	57                   	push   %edi
f0102783:	56                   	push   %esi
f0102784:	53                   	push   %ebx
f0102785:	83 ec 1c             	sub    $0x1c,%esp
f0102788:	8b 7d 08             	mov    0x8(%ebp),%edi
f010278b:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
 char * end = NULL;
    char * start = NULL;
    start = ROUNDDOWN((char *)va, PGSIZE); 
f010278e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102791:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102796:	89 c3                	mov    %eax,%ebx
f0102798:	89 45 e0             	mov    %eax,-0x20(%ebp)
    end = ROUNDUP((char *)(va + len), PGSIZE);
f010279b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010279e:	03 45 10             	add    0x10(%ebp),%eax
f01027a1:	05 ff 0f 00 00       	add    $0xfff,%eax
f01027a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01027ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pte_t *cur = NULL;

    for(; start < end; start += PGSIZE) {
f01027ae:	eb 4e                	jmp    f01027fe <user_mem_check+0x7f>
        cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
f01027b0:	83 ec 04             	sub    $0x4,%esp
f01027b3:	6a 00                	push   $0x0
f01027b5:	53                   	push   %ebx
f01027b6:	ff 77 5c             	pushl  0x5c(%edi)
f01027b9:	e8 60 e6 ff ff       	call   f0100e1e <pgdir_walk>
        if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
f01027be:	89 da                	mov    %ebx,%edx
f01027c0:	83 c4 10             	add    $0x10,%esp
f01027c3:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f01027c9:	77 0c                	ja     f01027d7 <user_mem_check+0x58>
f01027cb:	85 c0                	test   %eax,%eax
f01027cd:	74 08                	je     f01027d7 <user_mem_check+0x58>
f01027cf:	89 f1                	mov    %esi,%ecx
f01027d1:	23 08                	and    (%eax),%ecx
f01027d3:	39 ce                	cmp    %ecx,%esi
f01027d5:	74 21                	je     f01027f8 <user_mem_check+0x79>
              if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f01027d7:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f01027da:	75 0f                	jne    f01027eb <user_mem_check+0x6c>
                    user_mem_check_addr = (uintptr_t)va;
f01027dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027df:	a3 3c ce 17 f0       	mov    %eax,0xf017ce3c
              }
              else {
                      user_mem_check_addr = (uintptr_t)start;
              }
              return -E_FAULT;
f01027e4:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01027e9:	eb 1d                	jmp    f0102808 <user_mem_check+0x89>
        if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
              if(start == ROUNDDOWN((char *)va, PGSIZE)) {
                    user_mem_check_addr = (uintptr_t)va;
              }
              else {
                      user_mem_check_addr = (uintptr_t)start;
f01027eb:	89 15 3c ce 17 f0    	mov    %edx,0xf017ce3c
              }
              return -E_FAULT;
f01027f1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01027f6:	eb 10                	jmp    f0102808 <user_mem_check+0x89>
    char * start = NULL;
    start = ROUNDDOWN((char *)va, PGSIZE); 
    end = ROUNDUP((char *)(va + len), PGSIZE);
    pte_t *cur = NULL;

    for(; start < end; start += PGSIZE) {
f01027f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027fe:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102801:	72 ad                	jb     f01027b0 <user_mem_check+0x31>
              }
              return -E_FAULT;
        }
    }
        
    return 0;
f0102803:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102808:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010280b:	5b                   	pop    %ebx
f010280c:	5e                   	pop    %esi
f010280d:	5f                   	pop    %edi
f010280e:	5d                   	pop    %ebp
f010280f:	c3                   	ret    

f0102810 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102810:	55                   	push   %ebp
f0102811:	89 e5                	mov    %esp,%ebp
f0102813:	53                   	push   %ebx
f0102814:	83 ec 04             	sub    $0x4,%esp
f0102817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010281a:	8b 45 14             	mov    0x14(%ebp),%eax
f010281d:	83 c8 04             	or     $0x4,%eax
f0102820:	50                   	push   %eax
f0102821:	ff 75 10             	pushl  0x10(%ebp)
f0102824:	ff 75 0c             	pushl  0xc(%ebp)
f0102827:	53                   	push   %ebx
f0102828:	e8 52 ff ff ff       	call   f010277f <user_mem_check>
f010282d:	83 c4 10             	add    $0x10,%esp
f0102830:	85 c0                	test   %eax,%eax
f0102832:	79 21                	jns    f0102855 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102834:	83 ec 04             	sub    $0x4,%esp
f0102837:	ff 35 3c ce 17 f0    	pushl  0xf017ce3c
f010283d:	ff 73 48             	pushl  0x48(%ebx)
f0102840:	68 24 57 10 f0       	push   $0xf0105724
f0102845:	e8 04 07 00 00       	call   f0102f4e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010284a:	89 1c 24             	mov    %ebx,(%esp)
f010284d:	e8 e3 05 00 00       	call   f0102e35 <env_destroy>
f0102852:	83 c4 10             	add    $0x10,%esp
	}
}
f0102855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102858:	c9                   	leave  
f0102859:	c3                   	ret    

f010285a <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010285a:	55                   	push   %ebp
f010285b:	89 e5                	mov    %esp,%ebp
f010285d:	57                   	push   %edi
f010285e:	56                   	push   %esi
f010285f:	53                   	push   %ebx
f0102860:	83 ec 0c             	sub    $0xc,%esp
f0102863:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
f0102865:	89 d3                	mov    %edx,%ebx
f0102867:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f010286d:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102874:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	struct PageInfo *p = NULL;
	void* i;
	int r;
	for(i=start; i<end; i+=PGSIZE){
f010287a:	eb 58                	jmp    f01028d4 <region_alloc+0x7a>
		p = page_alloc(0);
f010287c:	83 ec 0c             	sub    $0xc,%esp
f010287f:	6a 00                	push   $0x0
f0102881:	e8 ab e4 ff ff       	call   f0100d31 <page_alloc>
		if(p == NULL)
f0102886:	83 c4 10             	add    $0x10,%esp
f0102889:	85 c0                	test   %eax,%eax
f010288b:	75 17                	jne    f01028a4 <region_alloc+0x4a>
			panic(" region alloc, allocation failed.");
f010288d:	83 ec 04             	sub    $0x4,%esp
f0102890:	68 5c 57 10 f0       	push   $0xf010575c
f0102895:	68 29 01 00 00       	push   $0x129
f010289a:	68 46 58 10 f0       	push   $0xf0105846
f010289f:	e8 fc d7 ff ff       	call   f01000a0 <_panic>

		r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f01028a4:	6a 06                	push   $0x6
f01028a6:	53                   	push   %ebx
f01028a7:	50                   	push   %eax
f01028a8:	ff 77 5c             	pushl  0x5c(%edi)
f01028ab:	e8 fc e6 ff ff       	call   f0100fac <page_insert>
		if(r != 0) {
f01028b0:	83 c4 10             	add    $0x10,%esp
f01028b3:	85 c0                	test   %eax,%eax
f01028b5:	74 17                	je     f01028ce <region_alloc+0x74>
			panic("region alloc error");
f01028b7:	83 ec 04             	sub    $0x4,%esp
f01028ba:	68 51 58 10 f0       	push   $0xf0105851
f01028bf:	68 2d 01 00 00       	push   $0x12d
f01028c4:	68 46 58 10 f0       	push   $0xf0105846
f01028c9:	e8 d2 d7 ff ff       	call   f01000a0 <_panic>
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
	struct PageInfo *p = NULL;
	void* i;
	int r;
	for(i=start; i<end; i+=PGSIZE){
f01028ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028d4:	39 f3                	cmp    %esi,%ebx
f01028d6:	72 a4                	jb     f010287c <region_alloc+0x22>
		r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
		if(r != 0) {
			panic("region alloc error");
		}
	}
}
f01028d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01028db:	5b                   	pop    %ebx
f01028dc:	5e                   	pop    %esi
f01028dd:	5f                   	pop    %edi
f01028de:	5d                   	pop    %ebp
f01028df:	c3                   	ret    

f01028e0 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01028e0:	55                   	push   %ebp
f01028e1:	89 e5                	mov    %esp,%ebp
f01028e3:	8b 55 08             	mov    0x8(%ebp),%edx
f01028e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01028e9:	85 d2                	test   %edx,%edx
f01028eb:	75 11                	jne    f01028fe <envid2env+0x1e>
		*env_store = curenv;
f01028ed:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f01028f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01028f5:	89 01                	mov    %eax,(%ecx)
		return 0;
f01028f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01028fc:	eb 5e                	jmp    f010295c <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01028fe:	89 d0                	mov    %edx,%eax
f0102900:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102905:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102908:	c1 e0 05             	shl    $0x5,%eax
f010290b:	03 05 4c ce 17 f0    	add    0xf017ce4c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102911:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102915:	74 05                	je     f010291c <envid2env+0x3c>
f0102917:	3b 50 48             	cmp    0x48(%eax),%edx
f010291a:	74 10                	je     f010292c <envid2env+0x4c>
		*env_store = 0;
f010291c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010291f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102925:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010292a:	eb 30                	jmp    f010295c <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010292c:	84 c9                	test   %cl,%cl
f010292e:	74 22                	je     f0102952 <envid2env+0x72>
f0102930:	8b 15 48 ce 17 f0    	mov    0xf017ce48,%edx
f0102936:	39 d0                	cmp    %edx,%eax
f0102938:	74 18                	je     f0102952 <envid2env+0x72>
f010293a:	8b 4a 48             	mov    0x48(%edx),%ecx
f010293d:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102940:	74 10                	je     f0102952 <envid2env+0x72>
		*env_store = 0;
f0102942:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102945:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010294b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102950:	eb 0a                	jmp    f010295c <envid2env+0x7c>
	}

	*env_store = e;
f0102952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102955:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102957:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010295c:	5d                   	pop    %ebp
f010295d:	c3                   	ret    

f010295e <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010295e:	55                   	push   %ebp
f010295f:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102961:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102966:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102969:	b8 23 00 00 00       	mov    $0x23,%eax
f010296e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102970:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102972:	b8 10 00 00 00       	mov    $0x10,%eax
f0102977:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102979:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010297b:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010297d:	ea 84 29 10 f0 08 00 	ljmp   $0x8,$0xf0102984
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102984:	b8 00 00 00 00       	mov    $0x0,%eax
f0102989:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010298c:	5d                   	pop    %ebp
f010298d:	c3                   	ret    

f010298e <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010298e:	55                   	push   %ebp
f010298f:	89 e5                	mov    %esp,%ebp
f0102991:	56                   	push   %esi
f0102992:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
    	env_free_list = NULL;
    	for(i=NENV-1; i>=0; i--){
        	envs[i].env_id = 0;
f0102993:	8b 35 4c ce 17 f0    	mov    0xf017ce4c,%esi
f0102999:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f010299f:	8d 5e a0             	lea    -0x60(%esi),%ebx
f01029a2:	ba 00 00 00 00       	mov    $0x0,%edx
f01029a7:	89 c1                	mov    %eax,%ecx
f01029a9:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        	envs[i].env_status = ENV_FREE;
f01029b0:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		//向前添加
        	envs[i].env_link = env_free_list;
f01029b7:	89 50 44             	mov    %edx,0x44(%eax)
f01029ba:	83 e8 60             	sub    $0x60,%eax
        	env_free_list = &envs[i];
f01029bd:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
    	env_free_list = NULL;
    	for(i=NENV-1; i>=0; i--){
f01029bf:	39 d8                	cmp    %ebx,%eax
f01029c1:	75 e4                	jne    f01029a7 <env_init+0x19>
f01029c3:	89 35 50 ce 17 f0    	mov    %esi,0xf017ce50
		//向前添加
        	envs[i].env_link = env_free_list;
        	env_free_list = &envs[i];
    	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01029c9:	e8 90 ff ff ff       	call   f010295e <env_init_percpu>
}
f01029ce:	5b                   	pop    %ebx
f01029cf:	5e                   	pop    %esi
f01029d0:	5d                   	pop    %ebp
f01029d1:	c3                   	ret    

f01029d2 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01029d2:	55                   	push   %ebp
f01029d3:	89 e5                	mov    %esp,%ebp
f01029d5:	53                   	push   %ebx
f01029d6:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01029d9:	8b 1d 50 ce 17 f0    	mov    0xf017ce50,%ebx
f01029df:	85 db                	test   %ebx,%ebx
f01029e1:	0f 84 61 01 00 00    	je     f0102b48 <env_alloc+0x176>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01029e7:	83 ec 0c             	sub    $0xc,%esp
f01029ea:	6a 01                	push   $0x1
f01029ec:	e8 40 e3 ff ff       	call   f0100d31 <page_alloc>
f01029f1:	83 c4 10             	add    $0x10,%esp
f01029f4:	85 c0                	test   %eax,%eax
f01029f6:	0f 84 53 01 00 00    	je     f0102b4f <env_alloc+0x17d>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029fc:	89 c2                	mov    %eax,%edx
f01029fe:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0102a04:	c1 fa 03             	sar    $0x3,%edx
f0102a07:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a0a:	89 d1                	mov    %edx,%ecx
f0102a0c:	c1 e9 0c             	shr    $0xc,%ecx
f0102a0f:	3b 0d 04 db 17 f0    	cmp    0xf017db04,%ecx
f0102a15:	72 12                	jb     f0102a29 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a17:	52                   	push   %edx
f0102a18:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0102a1d:	6a 56                	push   $0x56
f0102a1f:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102a24:	e8 77 d6 ff ff       	call   f01000a0 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *)page2kva(p);
f0102a29:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102a2f:	89 53 5c             	mov    %edx,0x5c(%ebx)
	p->pp_ref++;
f0102a32:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0102a37:	b8 00 00 00 00       	mov    $0x0,%eax

	//Map the directory below UTOP.
	for(i = 0; i < PDX(UTOP); i++) {
		e->env_pgdir[i] = 0;        
f0102a3c:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102a3f:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0102a46:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *)page2kva(p);
	p->pp_ref++;

	//Map the directory below UTOP.
	for(i = 0; i < PDX(UTOP); i++) {
f0102a49:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102a4e:	75 ec                	jne    f0102a3c <env_alloc+0x6a>
		e->env_pgdir[i] = 0;        
	}

    	//Map the directory above UTOP
    	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
    	    e->env_pgdir[i] = kern_pgdir[i];
f0102a50:	8b 15 08 db 17 f0    	mov    0xf017db08,%edx
f0102a56:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102a59:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102a5c:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102a5f:	83 c0 04             	add    $0x4,%eax
	for(i = 0; i < PDX(UTOP); i++) {
		e->env_pgdir[i] = 0;        
	}

    	//Map the directory above UTOP
    	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f0102a62:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a67:	75 e7                	jne    f0102a50 <env_alloc+0x7e>
    	    e->env_pgdir[i] = kern_pgdir[i];
    	}
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102a69:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a6c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a71:	77 15                	ja     f0102a88 <env_alloc+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a73:	50                   	push   %eax
f0102a74:	68 e0 50 10 f0       	push   $0xf01050e0
f0102a79:	68 cc 00 00 00       	push   $0xcc
f0102a7e:	68 46 58 10 f0       	push   $0xf0105846
f0102a83:	e8 18 d6 ff ff       	call   f01000a0 <_panic>
f0102a88:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102a8e:	83 ca 05             	or     $0x5,%edx
f0102a91:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102a97:	8b 43 48             	mov    0x48(%ebx),%eax
f0102a9a:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102a9f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102aa4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102aa9:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102aac:	89 da                	mov    %ebx,%edx
f0102aae:	2b 15 4c ce 17 f0    	sub    0xf017ce4c,%edx
f0102ab4:	c1 fa 05             	sar    $0x5,%edx
f0102ab7:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102abd:	09 d0                	or     %edx,%eax
f0102abf:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ac5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102ac8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102acf:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102ad6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102add:	83 ec 04             	sub    $0x4,%esp
f0102ae0:	6a 44                	push   $0x44
f0102ae2:	6a 00                	push   $0x0
f0102ae4:	53                   	push   %ebx
f0102ae5:	e8 24 18 00 00       	call   f010430e <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102aea:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102af0:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102af6:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102afc:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102b03:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102b09:	8b 43 44             	mov    0x44(%ebx),%eax
f0102b0c:	a3 50 ce 17 f0       	mov    %eax,0xf017ce50
	*newenv_store = e;
f0102b11:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b14:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102b16:	8b 53 48             	mov    0x48(%ebx),%edx
f0102b19:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f0102b1e:	83 c4 10             	add    $0x10,%esp
f0102b21:	85 c0                	test   %eax,%eax
f0102b23:	74 05                	je     f0102b2a <env_alloc+0x158>
f0102b25:	8b 40 48             	mov    0x48(%eax),%eax
f0102b28:	eb 05                	jmp    f0102b2f <env_alloc+0x15d>
f0102b2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b2f:	83 ec 04             	sub    $0x4,%esp
f0102b32:	52                   	push   %edx
f0102b33:	50                   	push   %eax
f0102b34:	68 64 58 10 f0       	push   $0xf0105864
f0102b39:	e8 10 04 00 00       	call   f0102f4e <cprintf>
	return 0;
f0102b3e:	83 c4 10             	add    $0x10,%esp
f0102b41:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b46:	eb 0c                	jmp    f0102b54 <env_alloc+0x182>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102b48:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102b4d:	eb 05                	jmp    f0102b54 <env_alloc+0x182>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102b4f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102b57:	c9                   	leave  
f0102b58:	c3                   	ret    

f0102b59 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102b59:	55                   	push   %ebp
f0102b5a:	89 e5                	mov    %esp,%ebp
f0102b5c:	57                   	push   %edi
f0102b5d:	56                   	push   %esi
f0102b5e:	53                   	push   %ebx
f0102b5f:	83 ec 34             	sub    $0x34,%esp
f0102b62:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int rc;
	if((rc = env_alloc(&e, 0)) != 0) {
f0102b65:	6a 00                	push   $0x0
f0102b67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102b6a:	50                   	push   %eax
f0102b6b:	e8 62 fe ff ff       	call   f01029d2 <env_alloc>
f0102b70:	83 c4 10             	add    $0x10,%esp
f0102b73:	85 c0                	test   %eax,%eax
f0102b75:	74 17                	je     f0102b8e <env_create+0x35>
		panic("env_create failed: env_alloc failed.\n");
f0102b77:	83 ec 04             	sub    $0x4,%esp
f0102b7a:	68 80 57 10 f0       	push   $0xf0105780
f0102b7f:	68 99 01 00 00       	push   $0x199
f0102b84:	68 46 58 10 f0       	push   $0xf0105846
f0102b89:	e8 12 d5 ff ff       	call   f01000a0 <_panic>
	}

	load_icode(e, binary);
f0102b8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b91:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf* header = (struct Elf*)binary;
    
	if(header->e_magic != ELF_MAGIC) {
f0102b94:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102b9a:	74 17                	je     f0102bb3 <env_create+0x5a>
		panic("load_icode failed: The binary we load is not elf.\n");
f0102b9c:	83 ec 04             	sub    $0x4,%esp
f0102b9f:	68 a8 57 10 f0       	push   $0xf01057a8
f0102ba4:	68 6b 01 00 00       	push   $0x16b
f0102ba9:	68 46 58 10 f0       	push   $0xf0105846
f0102bae:	e8 ed d4 ff ff       	call   f01000a0 <_panic>
	}

	if(header->e_entry == 0){
f0102bb3:	8b 47 18             	mov    0x18(%edi),%eax
f0102bb6:	85 c0                	test   %eax,%eax
f0102bb8:	75 17                	jne    f0102bd1 <env_create+0x78>
		panic("load_icode failed: The elf file can't be excuterd.\n");
f0102bba:	83 ec 04             	sub    $0x4,%esp
f0102bbd:	68 dc 57 10 f0       	push   $0xf01057dc
f0102bc2:	68 6f 01 00 00       	push   $0x16f
f0102bc7:	68 46 58 10 f0       	push   $0xf0105846
f0102bcc:	e8 cf d4 ff ff       	call   f01000a0 <_panic>
	}

	e->env_tf.tf_eip = header->e_entry;
f0102bd1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bd4:	89 41 30             	mov    %eax,0x30(%ecx)

	lcr3(PADDR(e->env_pgdir));   //?????
f0102bd7:	8b 41 5c             	mov    0x5c(%ecx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bda:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bdf:	77 15                	ja     f0102bf6 <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102be1:	50                   	push   %eax
f0102be2:	68 e0 50 10 f0       	push   $0xf01050e0
f0102be7:	68 74 01 00 00       	push   $0x174
f0102bec:	68 46 58 10 f0       	push   $0xf0105846
f0102bf1:	e8 aa d4 ff ff       	call   f01000a0 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102bf6:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bfb:	0f 22 d8             	mov    %eax,%cr3

	struct Proghdr *ph, *eph;
	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
f0102bfe:	89 fb                	mov    %edi,%ebx
f0102c00:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + header->e_phnum;
f0102c03:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102c07:	c1 e6 05             	shl    $0x5,%esi
f0102c0a:	01 de                	add    %ebx,%esi
f0102c0c:	eb 44                	jmp    f0102c52 <env_create+0xf9>
	for(; ph < eph; ph++) {
		if(ph->p_type == ELF_PROG_LOAD) {
f0102c0e:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102c11:	75 3c                	jne    f0102c4f <env_create+0xf6>
			if(ph->p_memsz - ph->p_filesz < 0) {
				panic("load icode failed : p_memsz < p_filesz.\n");
			}

			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102c13:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102c16:	8b 53 08             	mov    0x8(%ebx),%edx
f0102c19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c1c:	e8 39 fc ff ff       	call   f010285a <region_alloc>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102c21:	83 ec 04             	sub    $0x4,%esp
f0102c24:	ff 73 10             	pushl  0x10(%ebx)
f0102c27:	89 f8                	mov    %edi,%eax
f0102c29:	03 43 04             	add    0x4(%ebx),%eax
f0102c2c:	50                   	push   %eax
f0102c2d:	ff 73 08             	pushl  0x8(%ebx)
f0102c30:	e8 26 17 00 00       	call   f010435b <memmove>
			memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0102c35:	8b 43 10             	mov    0x10(%ebx),%eax
f0102c38:	83 c4 0c             	add    $0xc,%esp
f0102c3b:	8b 53 14             	mov    0x14(%ebx),%edx
f0102c3e:	29 c2                	sub    %eax,%edx
f0102c40:	52                   	push   %edx
f0102c41:	6a 00                	push   $0x0
f0102c43:	03 43 08             	add    0x8(%ebx),%eax
f0102c46:	50                   	push   %eax
f0102c47:	e8 c2 16 00 00       	call   f010430e <memset>
f0102c4c:	83 c4 10             	add    $0x10,%esp
	lcr3(PADDR(e->env_pgdir));   //?????

	struct Proghdr *ph, *eph;
	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
	eph = ph + header->e_phnum;
	for(; ph < eph; ph++) {
f0102c4f:	83 c3 20             	add    $0x20,%ebx
f0102c52:	39 de                	cmp    %ebx,%esi
f0102c54:	77 b8                	ja     f0102c0e <env_create+0xb5>
		}
	} 
     
    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.
	region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f0102c56:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102c5b:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102c60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c63:	e8 f2 fb ff ff       	call   f010285a <region_alloc>
	if((rc = env_alloc(&e, 0)) != 0) {
		panic("env_create failed: env_alloc failed.\n");
	}

	load_icode(e, binary);
	e->env_type = type;
f0102c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102c6e:	89 50 50             	mov    %edx,0x50(%eax)
}
f0102c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c74:	5b                   	pop    %ebx
f0102c75:	5e                   	pop    %esi
f0102c76:	5f                   	pop    %edi
f0102c77:	5d                   	pop    %ebp
f0102c78:	c3                   	ret    

f0102c79 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102c79:	55                   	push   %ebp
f0102c7a:	89 e5                	mov    %esp,%ebp
f0102c7c:	57                   	push   %edi
f0102c7d:	56                   	push   %esi
f0102c7e:	53                   	push   %ebx
f0102c7f:	83 ec 1c             	sub    $0x1c,%esp
f0102c82:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102c85:	8b 15 48 ce 17 f0    	mov    0xf017ce48,%edx
f0102c8b:	39 fa                	cmp    %edi,%edx
f0102c8d:	75 29                	jne    f0102cb8 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102c8f:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c94:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c99:	77 15                	ja     f0102cb0 <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c9b:	50                   	push   %eax
f0102c9c:	68 e0 50 10 f0       	push   $0xf01050e0
f0102ca1:	68 ae 01 00 00       	push   $0x1ae
f0102ca6:	68 46 58 10 f0       	push   $0xf0105846
f0102cab:	e8 f0 d3 ff ff       	call   f01000a0 <_panic>
f0102cb0:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cb5:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102cb8:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102cbb:	85 d2                	test   %edx,%edx
f0102cbd:	74 05                	je     f0102cc4 <env_free+0x4b>
f0102cbf:	8b 42 48             	mov    0x48(%edx),%eax
f0102cc2:	eb 05                	jmp    f0102cc9 <env_free+0x50>
f0102cc4:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cc9:	83 ec 04             	sub    $0x4,%esp
f0102ccc:	51                   	push   %ecx
f0102ccd:	50                   	push   %eax
f0102cce:	68 79 58 10 f0       	push   $0xf0105879
f0102cd3:	e8 76 02 00 00       	call   f0102f4e <cprintf>
f0102cd8:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102cdb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102ce2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102ce5:	89 d0                	mov    %edx,%eax
f0102ce7:	c1 e0 02             	shl    $0x2,%eax
f0102cea:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102ced:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102cf0:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102cf3:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102cf9:	0f 84 a8 00 00 00    	je     f0102da7 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102cff:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d05:	89 f0                	mov    %esi,%eax
f0102d07:	c1 e8 0c             	shr    $0xc,%eax
f0102d0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d0d:	39 05 04 db 17 f0    	cmp    %eax,0xf017db04
f0102d13:	77 15                	ja     f0102d2a <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d15:	56                   	push   %esi
f0102d16:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0102d1b:	68 bd 01 00 00       	push   $0x1bd
f0102d20:	68 46 58 10 f0       	push   $0xf0105846
f0102d25:	e8 76 d3 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d2d:	c1 e0 16             	shl    $0x16,%eax
f0102d30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d33:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102d38:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102d3f:	01 
f0102d40:	74 17                	je     f0102d59 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d42:	83 ec 08             	sub    $0x8,%esp
f0102d45:	89 d8                	mov    %ebx,%eax
f0102d47:	c1 e0 0c             	shl    $0xc,%eax
f0102d4a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102d4d:	50                   	push   %eax
f0102d4e:	ff 77 5c             	pushl  0x5c(%edi)
f0102d51:	e8 14 e2 ff ff       	call   f0100f6a <page_remove>
f0102d56:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d59:	83 c3 01             	add    $0x1,%ebx
f0102d5c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102d62:	75 d4                	jne    f0102d38 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102d64:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d67:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102d6a:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d71:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102d74:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102d7a:	72 14                	jb     f0102d90 <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102d7c:	83 ec 04             	sub    $0x4,%esp
f0102d7f:	68 84 50 10 f0       	push   $0xf0105084
f0102d84:	6a 4f                	push   $0x4f
f0102d86:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102d8b:	e8 10 d3 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102d90:	83 ec 0c             	sub    $0xc,%esp
f0102d93:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
f0102d98:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d9b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102d9e:	50                   	push   %eax
f0102d9f:	e8 53 e0 ff ff       	call   f0100df7 <page_decref>
f0102da4:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102da7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102dab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dae:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102db3:	0f 85 29 ff ff ff    	jne    f0102ce2 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102db9:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dbc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dc1:	77 15                	ja     f0102dd8 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dc3:	50                   	push   %eax
f0102dc4:	68 e0 50 10 f0       	push   $0xf01050e0
f0102dc9:	68 cb 01 00 00       	push   $0x1cb
f0102dce:	68 46 58 10 f0       	push   $0xf0105846
f0102dd3:	e8 c8 d2 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102dd8:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ddf:	05 00 00 00 10       	add    $0x10000000,%eax
f0102de4:	c1 e8 0c             	shr    $0xc,%eax
f0102de7:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102ded:	72 14                	jb     f0102e03 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102def:	83 ec 04             	sub    $0x4,%esp
f0102df2:	68 84 50 10 f0       	push   $0xf0105084
f0102df7:	6a 4f                	push   $0x4f
f0102df9:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102dfe:	e8 9d d2 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102e03:	83 ec 0c             	sub    $0xc,%esp
f0102e06:	8b 15 0c db 17 f0    	mov    0xf017db0c,%edx
f0102e0c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102e0f:	50                   	push   %eax
f0102e10:	e8 e2 df ff ff       	call   f0100df7 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102e15:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102e1c:	a1 50 ce 17 f0       	mov    0xf017ce50,%eax
f0102e21:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102e24:	89 3d 50 ce 17 f0    	mov    %edi,0xf017ce50
}
f0102e2a:	83 c4 10             	add    $0x10,%esp
f0102e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e30:	5b                   	pop    %ebx
f0102e31:	5e                   	pop    %esi
f0102e32:	5f                   	pop    %edi
f0102e33:	5d                   	pop    %ebp
f0102e34:	c3                   	ret    

f0102e35 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102e35:	55                   	push   %ebp
f0102e36:	89 e5                	mov    %esp,%ebp
f0102e38:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102e3b:	ff 75 08             	pushl  0x8(%ebp)
f0102e3e:	e8 36 fe ff ff       	call   f0102c79 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102e43:	c7 04 24 10 58 10 f0 	movl   $0xf0105810,(%esp)
f0102e4a:	e8 ff 00 00 00       	call   f0102f4e <cprintf>
f0102e4f:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102e52:	83 ec 0c             	sub    $0xc,%esp
f0102e55:	6a 00                	push   $0x0
f0102e57:	e8 50 d9 ff ff       	call   f01007ac <monitor>
f0102e5c:	83 c4 10             	add    $0x10,%esp
f0102e5f:	eb f1                	jmp    f0102e52 <env_destroy+0x1d>

f0102e61 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102e61:	55                   	push   %ebp
f0102e62:	89 e5                	mov    %esp,%ebp
f0102e64:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102e67:	8b 65 08             	mov    0x8(%ebp),%esp
f0102e6a:	61                   	popa   
f0102e6b:	07                   	pop    %es
f0102e6c:	1f                   	pop    %ds
f0102e6d:	83 c4 08             	add    $0x8,%esp
f0102e70:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102e71:	68 8f 58 10 f0       	push   $0xf010588f
f0102e76:	68 f3 01 00 00       	push   $0x1f3
f0102e7b:	68 46 58 10 f0       	push   $0xf0105846
f0102e80:	e8 1b d2 ff ff       	call   f01000a0 <_panic>

f0102e85 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102e85:	55                   	push   %ebp
f0102e86:	89 e5                	mov    %esp,%ebp
f0102e88:	83 ec 08             	sub    $0x8,%esp
f0102e8b:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING) {
f0102e8e:	8b 15 48 ce 17 f0    	mov    0xf017ce48,%edx
f0102e94:	85 d2                	test   %edx,%edx
f0102e96:	74 0d                	je     f0102ea5 <env_run+0x20>
f0102e98:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102e9c:	75 07                	jne    f0102ea5 <env_run+0x20>
		curenv->env_status = ENV_RUNNABLE;
f0102e9e:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	}

	curenv = e;
f0102ea5:	a3 48 ce 17 f0       	mov    %eax,0xf017ce48
	curenv->env_status = ENV_RUNNING;
f0102eaa:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0102eb1:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0102eb5:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102eb8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ebe:	77 15                	ja     f0102ed5 <env_run+0x50>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ec0:	52                   	push   %edx
f0102ec1:	68 e0 50 10 f0       	push   $0xf01050e0
f0102ec6:	68 18 02 00 00       	push   $0x218
f0102ecb:	68 46 58 10 f0       	push   $0xf0105846
f0102ed0:	e8 cb d1 ff ff       	call   f01000a0 <_panic>
f0102ed5:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102edb:	0f 22 da             	mov    %edx,%cr3

	env_pop_tf(&curenv->env_tf);
f0102ede:	83 ec 0c             	sub    $0xc,%esp
f0102ee1:	50                   	push   %eax
f0102ee2:	e8 7a ff ff ff       	call   f0102e61 <env_pop_tf>

f0102ee7 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ee7:	55                   	push   %ebp
f0102ee8:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102eea:	ba 70 00 00 00       	mov    $0x70,%edx
f0102eef:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ef2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102ef3:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ef8:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102ef9:	0f b6 c0             	movzbl %al,%eax
}
f0102efc:	5d                   	pop    %ebp
f0102efd:	c3                   	ret    

f0102efe <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102efe:	55                   	push   %ebp
f0102eff:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f01:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f06:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f09:	ee                   	out    %al,(%dx)
f0102f0a:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f12:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f13:	5d                   	pop    %ebp
f0102f14:	c3                   	ret    

f0102f15 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f15:	55                   	push   %ebp
f0102f16:	89 e5                	mov    %esp,%ebp
f0102f18:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102f1b:	ff 75 08             	pushl  0x8(%ebp)
f0102f1e:	e8 e4 d6 ff ff       	call   f0100607 <cputchar>
	*cnt++;
}
f0102f23:	83 c4 10             	add    $0x10,%esp
f0102f26:	c9                   	leave  
f0102f27:	c3                   	ret    

f0102f28 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f28:	55                   	push   %ebp
f0102f29:	89 e5                	mov    %esp,%ebp
f0102f2b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102f2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f35:	ff 75 0c             	pushl  0xc(%ebp)
f0102f38:	ff 75 08             	pushl  0x8(%ebp)
f0102f3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f3e:	50                   	push   %eax
f0102f3f:	68 15 2f 10 f0       	push   $0xf0102f15
f0102f44:	e8 ac 0c 00 00       	call   f0103bf5 <vprintfmt>
	return cnt;
}
f0102f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f4c:	c9                   	leave  
f0102f4d:	c3                   	ret    

f0102f4e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f4e:	55                   	push   %ebp
f0102f4f:	89 e5                	mov    %esp,%ebp
f0102f51:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f54:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f57:	50                   	push   %eax
f0102f58:	ff 75 08             	pushl  0x8(%ebp)
f0102f5b:	e8 c8 ff ff ff       	call   f0102f28 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f60:	c9                   	leave  
f0102f61:	c3                   	ret    

f0102f62 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102f62:	55                   	push   %ebp
f0102f63:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102f65:	b8 80 d6 17 f0       	mov    $0xf017d680,%eax
f0102f6a:	c7 05 84 d6 17 f0 00 	movl   $0xf0000000,0xf017d684
f0102f71:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102f74:	66 c7 05 88 d6 17 f0 	movw   $0x10,0xf017d688
f0102f7b:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102f7d:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f0102f84:	67 00 
f0102f86:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f0102f8c:	89 c2                	mov    %eax,%edx
f0102f8e:	c1 ea 10             	shr    $0x10,%edx
f0102f91:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0102f97:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f0102f9e:	c1 e8 18             	shr    $0x18,%eax
f0102fa1:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102fa6:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0102fad:	b8 28 00 00 00       	mov    $0x28,%eax
f0102fb2:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0102fb5:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0102fba:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102fbd:	5d                   	pop    %ebp
f0102fbe:	c3                   	ret    

f0102fbf <trap_init>:
}


void
trap_init(void)
{
f0102fbf:	55                   	push   %ebp
f0102fc0:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0102fc2:	b8 78 36 10 f0       	mov    $0xf0103678,%eax
f0102fc7:	66 a3 60 ce 17 f0    	mov    %ax,0xf017ce60
f0102fcd:	66 c7 05 62 ce 17 f0 	movw   $0x8,0xf017ce62
f0102fd4:	08 00 
f0102fd6:	c6 05 64 ce 17 f0 00 	movb   $0x0,0xf017ce64
f0102fdd:	c6 05 65 ce 17 f0 8e 	movb   $0x8e,0xf017ce65
f0102fe4:	c1 e8 10             	shr    $0x10,%eax
f0102fe7:	66 a3 66 ce 17 f0    	mov    %ax,0xf017ce66
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0102fed:	b8 7e 36 10 f0       	mov    $0xf010367e,%eax
f0102ff2:	66 a3 68 ce 17 f0    	mov    %ax,0xf017ce68
f0102ff8:	66 c7 05 6a ce 17 f0 	movw   $0x8,0xf017ce6a
f0102fff:	08 00 
f0103001:	c6 05 6c ce 17 f0 00 	movb   $0x0,0xf017ce6c
f0103008:	c6 05 6d ce 17 f0 8e 	movb   $0x8e,0xf017ce6d
f010300f:	c1 e8 10             	shr    $0x10,%eax
f0103012:	66 a3 6e ce 17 f0    	mov    %ax,0xf017ce6e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103018:	b8 84 36 10 f0       	mov    $0xf0103684,%eax
f010301d:	66 a3 70 ce 17 f0    	mov    %ax,0xf017ce70
f0103023:	66 c7 05 72 ce 17 f0 	movw   $0x8,0xf017ce72
f010302a:	08 00 
f010302c:	c6 05 74 ce 17 f0 00 	movb   $0x0,0xf017ce74
f0103033:	c6 05 75 ce 17 f0 8e 	movb   $0x8e,0xf017ce75
f010303a:	c1 e8 10             	shr    $0x10,%eax
f010303d:	66 a3 76 ce 17 f0    	mov    %ax,0xf017ce76
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103043:	b8 8a 36 10 f0       	mov    $0xf010368a,%eax
f0103048:	66 a3 78 ce 17 f0    	mov    %ax,0xf017ce78
f010304e:	66 c7 05 7a ce 17 f0 	movw   $0x8,0xf017ce7a
f0103055:	08 00 
f0103057:	c6 05 7c ce 17 f0 00 	movb   $0x0,0xf017ce7c
f010305e:	c6 05 7d ce 17 f0 ee 	movb   $0xee,0xf017ce7d
f0103065:	c1 e8 10             	shr    $0x10,%eax
f0103068:	66 a3 7e ce 17 f0    	mov    %ax,0xf017ce7e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f010306e:	b8 90 36 10 f0       	mov    $0xf0103690,%eax
f0103073:	66 a3 80 ce 17 f0    	mov    %ax,0xf017ce80
f0103079:	66 c7 05 82 ce 17 f0 	movw   $0x8,0xf017ce82
f0103080:	08 00 
f0103082:	c6 05 84 ce 17 f0 00 	movb   $0x0,0xf017ce84
f0103089:	c6 05 85 ce 17 f0 8e 	movb   $0x8e,0xf017ce85
f0103090:	c1 e8 10             	shr    $0x10,%eax
f0103093:	66 a3 86 ce 17 f0    	mov    %ax,0xf017ce86
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103099:	b8 96 36 10 f0       	mov    $0xf0103696,%eax
f010309e:	66 a3 88 ce 17 f0    	mov    %ax,0xf017ce88
f01030a4:	66 c7 05 8a ce 17 f0 	movw   $0x8,0xf017ce8a
f01030ab:	08 00 
f01030ad:	c6 05 8c ce 17 f0 00 	movb   $0x0,0xf017ce8c
f01030b4:	c6 05 8d ce 17 f0 8e 	movb   $0x8e,0xf017ce8d
f01030bb:	c1 e8 10             	shr    $0x10,%eax
f01030be:	66 a3 8e ce 17 f0    	mov    %ax,0xf017ce8e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f01030c4:	b8 9c 36 10 f0       	mov    $0xf010369c,%eax
f01030c9:	66 a3 90 ce 17 f0    	mov    %ax,0xf017ce90
f01030cf:	66 c7 05 92 ce 17 f0 	movw   $0x8,0xf017ce92
f01030d6:	08 00 
f01030d8:	c6 05 94 ce 17 f0 00 	movb   $0x0,0xf017ce94
f01030df:	c6 05 95 ce 17 f0 8e 	movb   $0x8e,0xf017ce95
f01030e6:	c1 e8 10             	shr    $0x10,%eax
f01030e9:	66 a3 96 ce 17 f0    	mov    %ax,0xf017ce96
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01030ef:	b8 a2 36 10 f0       	mov    $0xf01036a2,%eax
f01030f4:	66 a3 98 ce 17 f0    	mov    %ax,0xf017ce98
f01030fa:	66 c7 05 9a ce 17 f0 	movw   $0x8,0xf017ce9a
f0103101:	08 00 
f0103103:	c6 05 9c ce 17 f0 00 	movb   $0x0,0xf017ce9c
f010310a:	c6 05 9d ce 17 f0 8e 	movb   $0x8e,0xf017ce9d
f0103111:	c1 e8 10             	shr    $0x10,%eax
f0103114:	66 a3 9e ce 17 f0    	mov    %ax,0xf017ce9e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f010311a:	b8 a8 36 10 f0       	mov    $0xf01036a8,%eax
f010311f:	66 a3 a0 ce 17 f0    	mov    %ax,0xf017cea0
f0103125:	66 c7 05 a2 ce 17 f0 	movw   $0x8,0xf017cea2
f010312c:	08 00 
f010312e:	c6 05 a4 ce 17 f0 00 	movb   $0x0,0xf017cea4
f0103135:	c6 05 a5 ce 17 f0 8e 	movb   $0x8e,0xf017cea5
f010313c:	c1 e8 10             	shr    $0x10,%eax
f010313f:	66 a3 a6 ce 17 f0    	mov    %ax,0xf017cea6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103145:	b8 ac 36 10 f0       	mov    $0xf01036ac,%eax
f010314a:	66 a3 b0 ce 17 f0    	mov    %ax,0xf017ceb0
f0103150:	66 c7 05 b2 ce 17 f0 	movw   $0x8,0xf017ceb2
f0103157:	08 00 
f0103159:	c6 05 b4 ce 17 f0 00 	movb   $0x0,0xf017ceb4
f0103160:	c6 05 b5 ce 17 f0 8e 	movb   $0x8e,0xf017ceb5
f0103167:	c1 e8 10             	shr    $0x10,%eax
f010316a:	66 a3 b6 ce 17 f0    	mov    %ax,0xf017ceb6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103170:	b8 b0 36 10 f0       	mov    $0xf01036b0,%eax
f0103175:	66 a3 b8 ce 17 f0    	mov    %ax,0xf017ceb8
f010317b:	66 c7 05 ba ce 17 f0 	movw   $0x8,0xf017ceba
f0103182:	08 00 
f0103184:	c6 05 bc ce 17 f0 00 	movb   $0x0,0xf017cebc
f010318b:	c6 05 bd ce 17 f0 8e 	movb   $0x8e,0xf017cebd
f0103192:	c1 e8 10             	shr    $0x10,%eax
f0103195:	66 a3 be ce 17 f0    	mov    %ax,0xf017cebe
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f010319b:	b8 b4 36 10 f0       	mov    $0xf01036b4,%eax
f01031a0:	66 a3 c0 ce 17 f0    	mov    %ax,0xf017cec0
f01031a6:	66 c7 05 c2 ce 17 f0 	movw   $0x8,0xf017cec2
f01031ad:	08 00 
f01031af:	c6 05 c4 ce 17 f0 00 	movb   $0x0,0xf017cec4
f01031b6:	c6 05 c5 ce 17 f0 8e 	movb   $0x8e,0xf017cec5
f01031bd:	c1 e8 10             	shr    $0x10,%eax
f01031c0:	66 a3 c6 ce 17 f0    	mov    %ax,0xf017cec6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f01031c6:	b8 b8 36 10 f0       	mov    $0xf01036b8,%eax
f01031cb:	66 a3 c8 ce 17 f0    	mov    %ax,0xf017cec8
f01031d1:	66 c7 05 ca ce 17 f0 	movw   $0x8,0xf017ceca
f01031d8:	08 00 
f01031da:	c6 05 cc ce 17 f0 00 	movb   $0x0,0xf017cecc
f01031e1:	c6 05 cd ce 17 f0 8e 	movb   $0x8e,0xf017cecd
f01031e8:	c1 e8 10             	shr    $0x10,%eax
f01031eb:	66 a3 ce ce 17 f0    	mov    %ax,0xf017cece
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01031f1:	b8 bc 36 10 f0       	mov    $0xf01036bc,%eax
f01031f6:	66 a3 d0 ce 17 f0    	mov    %ax,0xf017ced0
f01031fc:	66 c7 05 d2 ce 17 f0 	movw   $0x8,0xf017ced2
f0103203:	08 00 
f0103205:	c6 05 d4 ce 17 f0 00 	movb   $0x0,0xf017ced4
f010320c:	c6 05 d5 ce 17 f0 8e 	movb   $0x8e,0xf017ced5
f0103213:	c1 e8 10             	shr    $0x10,%eax
f0103216:	66 a3 d6 ce 17 f0    	mov    %ax,0xf017ced6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f010321c:	b8 c0 36 10 f0       	mov    $0xf01036c0,%eax
f0103221:	66 a3 e0 ce 17 f0    	mov    %ax,0xf017cee0
f0103227:	66 c7 05 e2 ce 17 f0 	movw   $0x8,0xf017cee2
f010322e:	08 00 
f0103230:	c6 05 e4 ce 17 f0 00 	movb   $0x0,0xf017cee4
f0103237:	c6 05 e5 ce 17 f0 8e 	movb   $0x8e,0xf017cee5
f010323e:	c1 e8 10             	shr    $0x10,%eax
f0103241:	66 a3 e6 ce 17 f0    	mov    %ax,0xf017cee6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103247:	b8 c6 36 10 f0       	mov    $0xf01036c6,%eax
f010324c:	66 a3 e8 ce 17 f0    	mov    %ax,0xf017cee8
f0103252:	66 c7 05 ea ce 17 f0 	movw   $0x8,0xf017ceea
f0103259:	08 00 
f010325b:	c6 05 ec ce 17 f0 00 	movb   $0x0,0xf017ceec
f0103262:	c6 05 ed ce 17 f0 8e 	movb   $0x8e,0xf017ceed
f0103269:	c1 e8 10             	shr    $0x10,%eax
f010326c:	66 a3 ee ce 17 f0    	mov    %ax,0xf017ceee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103272:	b8 ca 36 10 f0       	mov    $0xf01036ca,%eax
f0103277:	66 a3 f0 ce 17 f0    	mov    %ax,0xf017cef0
f010327d:	66 c7 05 f2 ce 17 f0 	movw   $0x8,0xf017cef2
f0103284:	08 00 
f0103286:	c6 05 f4 ce 17 f0 00 	movb   $0x0,0xf017cef4
f010328d:	c6 05 f5 ce 17 f0 8e 	movb   $0x8e,0xf017cef5
f0103294:	c1 e8 10             	shr    $0x10,%eax
f0103297:	66 a3 f6 ce 17 f0    	mov    %ax,0xf017cef6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f010329d:	b8 d0 36 10 f0       	mov    $0xf01036d0,%eax
f01032a2:	66 a3 f8 ce 17 f0    	mov    %ax,0xf017cef8
f01032a8:	66 c7 05 fa ce 17 f0 	movw   $0x8,0xf017cefa
f01032af:	08 00 
f01032b1:	c6 05 fc ce 17 f0 00 	movb   $0x0,0xf017cefc
f01032b8:	c6 05 fd ce 17 f0 8e 	movb   $0x8e,0xf017cefd
f01032bf:	c1 e8 10             	shr    $0x10,%eax
f01032c2:	66 a3 fe ce 17 f0    	mov    %ax,0xf017cefe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01032c8:	b8 d6 36 10 f0       	mov    $0xf01036d6,%eax
f01032cd:	66 a3 e0 cf 17 f0    	mov    %ax,0xf017cfe0
f01032d3:	66 c7 05 e2 cf 17 f0 	movw   $0x8,0xf017cfe2
f01032da:	08 00 
f01032dc:	c6 05 e4 cf 17 f0 00 	movb   $0x0,0xf017cfe4
f01032e3:	c6 05 e5 cf 17 f0 ee 	movb   $0xee,0xf017cfe5
f01032ea:	c1 e8 10             	shr    $0x10,%eax
f01032ed:	66 a3 e6 cf 17 f0    	mov    %ax,0xf017cfe6
	// Per-CPU setup 
	trap_init_percpu();
f01032f3:	e8 6a fc ff ff       	call   f0102f62 <trap_init_percpu>
}
f01032f8:	5d                   	pop    %ebp
f01032f9:	c3                   	ret    

f01032fa <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01032fa:	55                   	push   %ebp
f01032fb:	89 e5                	mov    %esp,%ebp
f01032fd:	53                   	push   %ebx
f01032fe:	83 ec 0c             	sub    $0xc,%esp
f0103301:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103304:	ff 33                	pushl  (%ebx)
f0103306:	68 9b 58 10 f0       	push   $0xf010589b
f010330b:	e8 3e fc ff ff       	call   f0102f4e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103310:	83 c4 08             	add    $0x8,%esp
f0103313:	ff 73 04             	pushl  0x4(%ebx)
f0103316:	68 aa 58 10 f0       	push   $0xf01058aa
f010331b:	e8 2e fc ff ff       	call   f0102f4e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103320:	83 c4 08             	add    $0x8,%esp
f0103323:	ff 73 08             	pushl  0x8(%ebx)
f0103326:	68 b9 58 10 f0       	push   $0xf01058b9
f010332b:	e8 1e fc ff ff       	call   f0102f4e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103330:	83 c4 08             	add    $0x8,%esp
f0103333:	ff 73 0c             	pushl  0xc(%ebx)
f0103336:	68 c8 58 10 f0       	push   $0xf01058c8
f010333b:	e8 0e fc ff ff       	call   f0102f4e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103340:	83 c4 08             	add    $0x8,%esp
f0103343:	ff 73 10             	pushl  0x10(%ebx)
f0103346:	68 d7 58 10 f0       	push   $0xf01058d7
f010334b:	e8 fe fb ff ff       	call   f0102f4e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103350:	83 c4 08             	add    $0x8,%esp
f0103353:	ff 73 14             	pushl  0x14(%ebx)
f0103356:	68 e6 58 10 f0       	push   $0xf01058e6
f010335b:	e8 ee fb ff ff       	call   f0102f4e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103360:	83 c4 08             	add    $0x8,%esp
f0103363:	ff 73 18             	pushl  0x18(%ebx)
f0103366:	68 f5 58 10 f0       	push   $0xf01058f5
f010336b:	e8 de fb ff ff       	call   f0102f4e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103370:	83 c4 08             	add    $0x8,%esp
f0103373:	ff 73 1c             	pushl  0x1c(%ebx)
f0103376:	68 04 59 10 f0       	push   $0xf0105904
f010337b:	e8 ce fb ff ff       	call   f0102f4e <cprintf>
}
f0103380:	83 c4 10             	add    $0x10,%esp
f0103383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103386:	c9                   	leave  
f0103387:	c3                   	ret    

f0103388 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103388:	55                   	push   %ebp
f0103389:	89 e5                	mov    %esp,%ebp
f010338b:	56                   	push   %esi
f010338c:	53                   	push   %ebx
f010338d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103390:	83 ec 08             	sub    $0x8,%esp
f0103393:	53                   	push   %ebx
f0103394:	68 3a 5a 10 f0       	push   $0xf0105a3a
f0103399:	e8 b0 fb ff ff       	call   f0102f4e <cprintf>
	print_regs(&tf->tf_regs);
f010339e:	89 1c 24             	mov    %ebx,(%esp)
f01033a1:	e8 54 ff ff ff       	call   f01032fa <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01033a6:	83 c4 08             	add    $0x8,%esp
f01033a9:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01033ad:	50                   	push   %eax
f01033ae:	68 55 59 10 f0       	push   $0xf0105955
f01033b3:	e8 96 fb ff ff       	call   f0102f4e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01033b8:	83 c4 08             	add    $0x8,%esp
f01033bb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01033bf:	50                   	push   %eax
f01033c0:	68 68 59 10 f0       	push   $0xf0105968
f01033c5:	e8 84 fb ff ff       	call   f0102f4e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033ca:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01033cd:	83 c4 10             	add    $0x10,%esp
f01033d0:	83 f8 13             	cmp    $0x13,%eax
f01033d3:	77 09                	ja     f01033de <print_trapframe+0x56>
		return excnames[trapno];
f01033d5:	8b 14 85 00 5c 10 f0 	mov    -0xfefa400(,%eax,4),%edx
f01033dc:	eb 10                	jmp    f01033ee <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01033de:	83 f8 30             	cmp    $0x30,%eax
f01033e1:	b9 1f 59 10 f0       	mov    $0xf010591f,%ecx
f01033e6:	ba 13 59 10 f0       	mov    $0xf0105913,%edx
f01033eb:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033ee:	83 ec 04             	sub    $0x4,%esp
f01033f1:	52                   	push   %edx
f01033f2:	50                   	push   %eax
f01033f3:	68 7b 59 10 f0       	push   $0xf010597b
f01033f8:	e8 51 fb ff ff       	call   f0102f4e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01033fd:	83 c4 10             	add    $0x10,%esp
f0103400:	3b 1d 60 d6 17 f0    	cmp    0xf017d660,%ebx
f0103406:	75 1a                	jne    f0103422 <print_trapframe+0x9a>
f0103408:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010340c:	75 14                	jne    f0103422 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010340e:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103411:	83 ec 08             	sub    $0x8,%esp
f0103414:	50                   	push   %eax
f0103415:	68 8d 59 10 f0       	push   $0xf010598d
f010341a:	e8 2f fb ff ff       	call   f0102f4e <cprintf>
f010341f:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103422:	83 ec 08             	sub    $0x8,%esp
f0103425:	ff 73 2c             	pushl  0x2c(%ebx)
f0103428:	68 9c 59 10 f0       	push   $0xf010599c
f010342d:	e8 1c fb ff ff       	call   f0102f4e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103432:	83 c4 10             	add    $0x10,%esp
f0103435:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103439:	75 49                	jne    f0103484 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010343b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010343e:	89 c2                	mov    %eax,%edx
f0103440:	83 e2 01             	and    $0x1,%edx
f0103443:	ba 39 59 10 f0       	mov    $0xf0105939,%edx
f0103448:	b9 2e 59 10 f0       	mov    $0xf010592e,%ecx
f010344d:	0f 44 ca             	cmove  %edx,%ecx
f0103450:	89 c2                	mov    %eax,%edx
f0103452:	83 e2 02             	and    $0x2,%edx
f0103455:	ba 4b 59 10 f0       	mov    $0xf010594b,%edx
f010345a:	be 45 59 10 f0       	mov    $0xf0105945,%esi
f010345f:	0f 45 d6             	cmovne %esi,%edx
f0103462:	83 e0 04             	and    $0x4,%eax
f0103465:	be 65 5a 10 f0       	mov    $0xf0105a65,%esi
f010346a:	b8 50 59 10 f0       	mov    $0xf0105950,%eax
f010346f:	0f 44 c6             	cmove  %esi,%eax
f0103472:	51                   	push   %ecx
f0103473:	52                   	push   %edx
f0103474:	50                   	push   %eax
f0103475:	68 aa 59 10 f0       	push   $0xf01059aa
f010347a:	e8 cf fa ff ff       	call   f0102f4e <cprintf>
f010347f:	83 c4 10             	add    $0x10,%esp
f0103482:	eb 10                	jmp    f0103494 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103484:	83 ec 0c             	sub    $0xc,%esp
f0103487:	68 69 4f 10 f0       	push   $0xf0104f69
f010348c:	e8 bd fa ff ff       	call   f0102f4e <cprintf>
f0103491:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103494:	83 ec 08             	sub    $0x8,%esp
f0103497:	ff 73 30             	pushl  0x30(%ebx)
f010349a:	68 b9 59 10 f0       	push   $0xf01059b9
f010349f:	e8 aa fa ff ff       	call   f0102f4e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01034a4:	83 c4 08             	add    $0x8,%esp
f01034a7:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01034ab:	50                   	push   %eax
f01034ac:	68 c8 59 10 f0       	push   $0xf01059c8
f01034b1:	e8 98 fa ff ff       	call   f0102f4e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01034b6:	83 c4 08             	add    $0x8,%esp
f01034b9:	ff 73 38             	pushl  0x38(%ebx)
f01034bc:	68 db 59 10 f0       	push   $0xf01059db
f01034c1:	e8 88 fa ff ff       	call   f0102f4e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01034c6:	83 c4 10             	add    $0x10,%esp
f01034c9:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01034cd:	74 25                	je     f01034f4 <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01034cf:	83 ec 08             	sub    $0x8,%esp
f01034d2:	ff 73 3c             	pushl  0x3c(%ebx)
f01034d5:	68 ea 59 10 f0       	push   $0xf01059ea
f01034da:	e8 6f fa ff ff       	call   f0102f4e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01034df:	83 c4 08             	add    $0x8,%esp
f01034e2:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01034e6:	50                   	push   %eax
f01034e7:	68 f9 59 10 f0       	push   $0xf01059f9
f01034ec:	e8 5d fa ff ff       	call   f0102f4e <cprintf>
f01034f1:	83 c4 10             	add    $0x10,%esp
	}
}
f01034f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01034f7:	5b                   	pop    %ebx
f01034f8:	5e                   	pop    %esi
f01034f9:	5d                   	pop    %ebp
f01034fa:	c3                   	ret    

f01034fb <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01034fb:	55                   	push   %ebp
f01034fc:	89 e5                	mov    %esp,%ebp
f01034fe:	53                   	push   %ebx
f01034ff:	83 ec 04             	sub    $0x4,%esp
f0103502:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103505:	0f 20 d0             	mov    %cr2,%eax
    
    // We've already handled kernel-mode exceptions, so if we get here,
    // the page fault happened in user mode.

    // Destroy the environment that caused the fault.
    cprintf("[%08x] user fault va %08x ip %08x\n",
f0103508:	ff 73 30             	pushl  0x30(%ebx)
f010350b:	50                   	push   %eax
f010350c:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f0103511:	ff 70 48             	pushl  0x48(%eax)
f0103514:	68 b0 5b 10 f0       	push   $0xf0105bb0
f0103519:	e8 30 fa ff ff       	call   f0102f4e <cprintf>
        curenv->env_id, fault_va, tf->tf_eip);
    print_trapframe(tf);
f010351e:	89 1c 24             	mov    %ebx,(%esp)
f0103521:	e8 62 fe ff ff       	call   f0103388 <print_trapframe>
    env_destroy(curenv);
f0103526:	83 c4 04             	add    $0x4,%esp
f0103529:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f010352f:	e8 01 f9 ff ff       	call   f0102e35 <env_destroy>
}
f0103534:	83 c4 10             	add    $0x10,%esp
f0103537:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010353a:	c9                   	leave  
f010353b:	c3                   	ret    

f010353c <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f010353c:	55                   	push   %ebp
f010353d:	89 e5                	mov    %esp,%ebp
f010353f:	57                   	push   %edi
f0103540:	56                   	push   %esi
f0103541:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103544:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103545:	9c                   	pushf  
f0103546:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103547:	f6 c4 02             	test   $0x2,%ah
f010354a:	74 19                	je     f0103565 <trap+0x29>
f010354c:	68 0c 5a 10 f0       	push   $0xf0105a0c
f0103551:	68 ba 4c 10 f0       	push   $0xf0104cba
f0103556:	68 e2 00 00 00       	push   $0xe2
f010355b:	68 25 5a 10 f0       	push   $0xf0105a25
f0103560:	e8 3b cb ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103565:	83 ec 08             	sub    $0x8,%esp
f0103568:	56                   	push   %esi
f0103569:	68 31 5a 10 f0       	push   $0xf0105a31
f010356e:	e8 db f9 ff ff       	call   f0102f4e <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103573:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103577:	83 e0 03             	and    $0x3,%eax
f010357a:	83 c4 10             	add    $0x10,%esp
f010357d:	66 83 f8 03          	cmp    $0x3,%ax
f0103581:	75 31                	jne    f01035b4 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f0103583:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f0103588:	85 c0                	test   %eax,%eax
f010358a:	75 19                	jne    f01035a5 <trap+0x69>
f010358c:	68 4c 5a 10 f0       	push   $0xf0105a4c
f0103591:	68 ba 4c 10 f0       	push   $0xf0104cba
f0103596:	68 e8 00 00 00       	push   $0xe8
f010359b:	68 25 5a 10 f0       	push   $0xf0105a25
f01035a0:	e8 fb ca ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01035a5:	b9 11 00 00 00       	mov    $0x11,%ecx
f01035aa:	89 c7                	mov    %eax,%edi
f01035ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01035ae:	8b 35 48 ce 17 f0    	mov    0xf017ce48,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01035b4:	89 35 60 d6 17 f0    	mov    %esi,0xf017d660
trap_dispatch(struct Trapframe *tf)
{
	int32_t ret_code;
    // Handle processor exceptions.
    // LAB 3: Your code here.
    switch(tf->tf_trapno) {
f01035ba:	8b 46 28             	mov    0x28(%esi),%eax
f01035bd:	83 f8 0e             	cmp    $0xe,%eax
f01035c0:	74 0c                	je     f01035ce <trap+0x92>
f01035c2:	83 f8 30             	cmp    $0x30,%eax
f01035c5:	74 23                	je     f01035ea <trap+0xae>
f01035c7:	83 f8 03             	cmp    $0x3,%eax
f01035ca:	75 3f                	jne    f010360b <trap+0xcf>
f01035cc:	eb 0e                	jmp    f01035dc <trap+0xa0>
        case (T_PGFLT):
            page_fault_handler(tf);
f01035ce:	83 ec 0c             	sub    $0xc,%esp
f01035d1:	56                   	push   %esi
f01035d2:	e8 24 ff ff ff       	call   f01034fb <page_fault_handler>
f01035d7:	83 c4 10             	add    $0x10,%esp
f01035da:	eb 6a                	jmp    f0103646 <trap+0x10a>
            break; 
        case (T_BRKPT):
            monitor(tf);        
f01035dc:	83 ec 0c             	sub    $0xc,%esp
f01035df:	56                   	push   %esi
f01035e0:	e8 c7 d1 ff ff       	call   f01007ac <monitor>
f01035e5:	83 c4 10             	add    $0x10,%esp
f01035e8:	eb 5c                	jmp    f0103646 <trap+0x10a>
            break;
        case (T_SYSCALL):
    //        print_trapframe(tf);
            ret_code = syscall(
f01035ea:	83 ec 08             	sub    $0x8,%esp
f01035ed:	ff 76 04             	pushl  0x4(%esi)
f01035f0:	ff 36                	pushl  (%esi)
f01035f2:	ff 76 10             	pushl  0x10(%esi)
f01035f5:	ff 76 18             	pushl  0x18(%esi)
f01035f8:	ff 76 14             	pushl  0x14(%esi)
f01035fb:	ff 76 1c             	pushl  0x1c(%esi)
f01035fe:	e8 eb 00 00 00       	call   f01036ee <syscall>
                    tf->tf_regs.reg_edx,
                    tf->tf_regs.reg_ecx,
                    tf->tf_regs.reg_ebx,
                    tf->tf_regs.reg_edi,
                    tf->tf_regs.reg_esi);
            tf->tf_regs.reg_eax = ret_code;
f0103603:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103606:	83 c4 20             	add    $0x20,%esp
f0103609:	eb 3b                	jmp    f0103646 <trap+0x10a>
            break;
         default:
            // Unexpected trap: The user process or the kernel has a bug.
            print_trapframe(tf);
f010360b:	83 ec 0c             	sub    $0xc,%esp
f010360e:	56                   	push   %esi
f010360f:	e8 74 fd ff ff       	call   f0103388 <print_trapframe>
            if (tf->tf_cs == GD_KT)
f0103614:	83 c4 10             	add    $0x10,%esp
f0103617:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010361c:	75 17                	jne    f0103635 <trap+0xf9>
                panic("unhandled trap in kernel");
f010361e:	83 ec 04             	sub    $0x4,%esp
f0103621:	68 53 5a 10 f0       	push   $0xf0105a53
f0103626:	68 d0 00 00 00       	push   $0xd0
f010362b:	68 25 5a 10 f0       	push   $0xf0105a25
f0103630:	e8 6b ca ff ff       	call   f01000a0 <_panic>
            else {
                env_destroy(curenv);
f0103635:	83 ec 0c             	sub    $0xc,%esp
f0103638:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f010363e:	e8 f2 f7 ff ff       	call   f0102e35 <env_destroy>
f0103643:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103646:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f010364b:	85 c0                	test   %eax,%eax
f010364d:	74 06                	je     f0103655 <trap+0x119>
f010364f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103653:	74 19                	je     f010366e <trap+0x132>
f0103655:	68 d4 5b 10 f0       	push   $0xf0105bd4
f010365a:	68 ba 4c 10 f0       	push   $0xf0104cba
f010365f:	68 fa 00 00 00       	push   $0xfa
f0103664:	68 25 5a 10 f0       	push   $0xf0105a25
f0103669:	e8 32 ca ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f010366e:	83 ec 0c             	sub    $0xc,%esp
f0103671:	50                   	push   %eax
f0103672:	e8 0e f8 ff ff       	call   f0102e85 <env_run>
f0103677:	90                   	nop

f0103678 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0103678:	6a 00                	push   $0x0
f010367a:	6a 00                	push   $0x0
f010367c:	eb 5e                	jmp    f01036dc <_alltraps>

f010367e <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f010367e:	6a 00                	push   $0x0
f0103680:	6a 01                	push   $0x1
f0103682:	eb 58                	jmp    f01036dc <_alltraps>

f0103684 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0103684:	6a 00                	push   $0x0
f0103686:	6a 02                	push   $0x2
f0103688:	eb 52                	jmp    f01036dc <_alltraps>

f010368a <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f010368a:	6a 00                	push   $0x0
f010368c:	6a 03                	push   $0x3
f010368e:	eb 4c                	jmp    f01036dc <_alltraps>

f0103690 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0103690:	6a 00                	push   $0x0
f0103692:	6a 04                	push   $0x4
f0103694:	eb 46                	jmp    f01036dc <_alltraps>

f0103696 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0103696:	6a 00                	push   $0x0
f0103698:	6a 05                	push   $0x5
f010369a:	eb 40                	jmp    f01036dc <_alltraps>

f010369c <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f010369c:	6a 00                	push   $0x0
f010369e:	6a 06                	push   $0x6
f01036a0:	eb 3a                	jmp    f01036dc <_alltraps>

f01036a2 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f01036a2:	6a 00                	push   $0x0
f01036a4:	6a 07                	push   $0x7
f01036a6:	eb 34                	jmp    f01036dc <_alltraps>

f01036a8 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f01036a8:	6a 08                	push   $0x8
f01036aa:	eb 30                	jmp    f01036dc <_alltraps>

f01036ac <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f01036ac:	6a 0a                	push   $0xa
f01036ae:	eb 2c                	jmp    f01036dc <_alltraps>

f01036b0 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f01036b0:	6a 0b                	push   $0xb
f01036b2:	eb 28                	jmp    f01036dc <_alltraps>

f01036b4 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f01036b4:	6a 0c                	push   $0xc
f01036b6:	eb 24                	jmp    f01036dc <_alltraps>

f01036b8 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f01036b8:	6a 0d                	push   $0xd
f01036ba:	eb 20                	jmp    f01036dc <_alltraps>

f01036bc <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f01036bc:	6a 0e                	push   $0xe
f01036be:	eb 1c                	jmp    f01036dc <_alltraps>

f01036c0 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f01036c0:	6a 00                	push   $0x0
f01036c2:	6a 10                	push   $0x10
f01036c4:	eb 16                	jmp    f01036dc <_alltraps>

f01036c6 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f01036c6:	6a 11                	push   $0x11
f01036c8:	eb 12                	jmp    f01036dc <_alltraps>

f01036ca <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f01036ca:	6a 00                	push   $0x0
f01036cc:	6a 12                	push   $0x12
f01036ce:	eb 0c                	jmp    f01036dc <_alltraps>

f01036d0 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f01036d0:	6a 00                	push   $0x0
f01036d2:	6a 13                	push   $0x13
f01036d4:	eb 06                	jmp    f01036dc <_alltraps>

f01036d6 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01036d6:	6a 00                	push   $0x0
f01036d8:	6a 30                	push   $0x30
f01036da:	eb 00                	jmp    f01036dc <_alltraps>

f01036dc <_alltraps>:

_alltraps:
	pushl %ds
f01036dc:	1e                   	push   %ds
        pushl %es
f01036dd:	06                   	push   %es
        pushal
f01036de:	60                   	pusha  

        movl $GD_KD, %eax
f01036df:	b8 10 00 00 00       	mov    $0x10,%eax
        movl %eax, %ds
f01036e4:	8e d8                	mov    %eax,%ds
        movl %eax, %es
f01036e6:	8e c0                	mov    %eax,%es

        push %esp
f01036e8:	54                   	push   %esp
        call trap
f01036e9:	e8 4e fe ff ff       	call   f010353c <trap>

f01036ee <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01036ee:	55                   	push   %ebp
f01036ef:	89 e5                	mov    %esp,%ebp
f01036f1:	83 ec 18             	sub    $0x18,%esp
f01036f4:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f01036f7:	83 f8 01             	cmp    $0x1,%eax
f01036fa:	74 44                	je     f0103740 <syscall+0x52>
f01036fc:	83 f8 01             	cmp    $0x1,%eax
f01036ff:	72 0f                	jb     f0103710 <syscall+0x22>
f0103701:	83 f8 02             	cmp    $0x2,%eax
f0103704:	74 41                	je     f0103747 <syscall+0x59>
f0103706:	83 f8 03             	cmp    $0x3,%eax
f0103709:	74 46                	je     f0103751 <syscall+0x63>
f010370b:	e9 a6 00 00 00       	jmp    f01037b6 <syscall+0xc8>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0103710:	6a 00                	push   $0x0
f0103712:	ff 75 10             	pushl  0x10(%ebp)
f0103715:	ff 75 0c             	pushl  0xc(%ebp)
f0103718:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f010371e:	e8 ed f0 ff ff       	call   f0102810 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103723:	83 c4 0c             	add    $0xc,%esp
f0103726:	ff 75 0c             	pushl  0xc(%ebp)
f0103729:	ff 75 10             	pushl  0x10(%ebp)
f010372c:	68 50 5c 10 f0       	push   $0xf0105c50
f0103731:	e8 18 f8 ff ff       	call   f0102f4e <cprintf>
f0103736:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");

	switch (syscallno) {
		case (SYS_cputs):
		    sys_cputs((const char *)a1, a2);
		    return 0;
f0103739:	b8 00 00 00 00       	mov    $0x0,%eax
f010373e:	eb 7b                	jmp    f01037bb <syscall+0xcd>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103740:	e8 70 cd ff ff       	call   f01004b5 <cons_getc>
	switch (syscallno) {
		case (SYS_cputs):
		    sys_cputs((const char *)a1, a2);
		    return 0;
		case (SYS_cgetc):
		    return sys_cgetc();
f0103745:	eb 74                	jmp    f01037bb <syscall+0xcd>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103747:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
f010374c:	8b 40 48             	mov    0x48(%eax),%eax
		    sys_cputs((const char *)a1, a2);
		    return 0;
		case (SYS_cgetc):
		    return sys_cgetc();
		case (SYS_getenvid):
		    return sys_getenvid();
f010374f:	eb 6a                	jmp    f01037bb <syscall+0xcd>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103751:	83 ec 04             	sub    $0x4,%esp
f0103754:	6a 01                	push   $0x1
f0103756:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103759:	50                   	push   %eax
f010375a:	ff 75 0c             	pushl  0xc(%ebp)
f010375d:	e8 7e f1 ff ff       	call   f01028e0 <envid2env>
f0103762:	83 c4 10             	add    $0x10,%esp
f0103765:	85 c0                	test   %eax,%eax
f0103767:	78 52                	js     f01037bb <syscall+0xcd>
		return r;
	if (e == curenv)
f0103769:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010376c:	8b 15 48 ce 17 f0    	mov    0xf017ce48,%edx
f0103772:	39 d0                	cmp    %edx,%eax
f0103774:	75 15                	jne    f010378b <syscall+0x9d>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103776:	83 ec 08             	sub    $0x8,%esp
f0103779:	ff 70 48             	pushl  0x48(%eax)
f010377c:	68 55 5c 10 f0       	push   $0xf0105c55
f0103781:	e8 c8 f7 ff ff       	call   f0102f4e <cprintf>
f0103786:	83 c4 10             	add    $0x10,%esp
f0103789:	eb 16                	jmp    f01037a1 <syscall+0xb3>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010378b:	83 ec 04             	sub    $0x4,%esp
f010378e:	ff 70 48             	pushl  0x48(%eax)
f0103791:	ff 72 48             	pushl  0x48(%edx)
f0103794:	68 70 5c 10 f0       	push   $0xf0105c70
f0103799:	e8 b0 f7 ff ff       	call   f0102f4e <cprintf>
f010379e:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01037a1:	83 ec 0c             	sub    $0xc,%esp
f01037a4:	ff 75 f4             	pushl  -0xc(%ebp)
f01037a7:	e8 89 f6 ff ff       	call   f0102e35 <env_destroy>
f01037ac:	83 c4 10             	add    $0x10,%esp
	return 0;
f01037af:	b8 00 00 00 00       	mov    $0x0,%eax
f01037b4:	eb 05                	jmp    f01037bb <syscall+0xcd>
		case (SYS_getenvid):
		    return sys_getenvid();
		case (SYS_env_destroy):
		    return sys_env_destroy(a1);
		default:
		    return -E_INVAL;
f01037b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    	}
}
f01037bb:	c9                   	leave  
f01037bc:	c3                   	ret    

f01037bd <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01037bd:	55                   	push   %ebp
f01037be:	89 e5                	mov    %esp,%ebp
f01037c0:	57                   	push   %edi
f01037c1:	56                   	push   %esi
f01037c2:	53                   	push   %ebx
f01037c3:	83 ec 14             	sub    $0x14,%esp
f01037c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01037c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01037cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01037cf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01037d2:	8b 1a                	mov    (%edx),%ebx
f01037d4:	8b 01                	mov    (%ecx),%eax
f01037d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01037d9:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01037e0:	eb 7f                	jmp    f0103861 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01037e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01037e5:	01 d8                	add    %ebx,%eax
f01037e7:	89 c6                	mov    %eax,%esi
f01037e9:	c1 ee 1f             	shr    $0x1f,%esi
f01037ec:	01 c6                	add    %eax,%esi
f01037ee:	d1 fe                	sar    %esi
f01037f0:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01037f3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01037f6:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01037f9:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01037fb:	eb 03                	jmp    f0103800 <stab_binsearch+0x43>
			m--;
f01037fd:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103800:	39 c3                	cmp    %eax,%ebx
f0103802:	7f 0d                	jg     f0103811 <stab_binsearch+0x54>
f0103804:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103808:	83 ea 0c             	sub    $0xc,%edx
f010380b:	39 f9                	cmp    %edi,%ecx
f010380d:	75 ee                	jne    f01037fd <stab_binsearch+0x40>
f010380f:	eb 05                	jmp    f0103816 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103811:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0103814:	eb 4b                	jmp    f0103861 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103816:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103819:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010381c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103820:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103823:	76 11                	jbe    f0103836 <stab_binsearch+0x79>
			*region_left = m;
f0103825:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103828:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010382a:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010382d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103834:	eb 2b                	jmp    f0103861 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103836:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103839:	73 14                	jae    f010384f <stab_binsearch+0x92>
			*region_right = m - 1;
f010383b:	83 e8 01             	sub    $0x1,%eax
f010383e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103841:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103844:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103846:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010384d:	eb 12                	jmp    f0103861 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010384f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103852:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103854:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103858:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010385a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103861:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103864:	0f 8e 78 ff ff ff    	jle    f01037e2 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010386a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010386e:	75 0f                	jne    f010387f <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0103870:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103873:	8b 00                	mov    (%eax),%eax
f0103875:	83 e8 01             	sub    $0x1,%eax
f0103878:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010387b:	89 06                	mov    %eax,(%esi)
f010387d:	eb 2c                	jmp    f01038ab <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010387f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103882:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103884:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103887:	8b 0e                	mov    (%esi),%ecx
f0103889:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010388c:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010388f:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103892:	eb 03                	jmp    f0103897 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103894:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103897:	39 c8                	cmp    %ecx,%eax
f0103899:	7e 0b                	jle    f01038a6 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010389b:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010389f:	83 ea 0c             	sub    $0xc,%edx
f01038a2:	39 df                	cmp    %ebx,%edi
f01038a4:	75 ee                	jne    f0103894 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01038a6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01038a9:	89 06                	mov    %eax,(%esi)
	}
}
f01038ab:	83 c4 14             	add    $0x14,%esp
f01038ae:	5b                   	pop    %ebx
f01038af:	5e                   	pop    %esi
f01038b0:	5f                   	pop    %edi
f01038b1:	5d                   	pop    %ebp
f01038b2:	c3                   	ret    

f01038b3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01038b3:	55                   	push   %ebp
f01038b4:	89 e5                	mov    %esp,%ebp
f01038b6:	57                   	push   %edi
f01038b7:	56                   	push   %esi
f01038b8:	53                   	push   %ebx
f01038b9:	83 ec 3c             	sub    $0x3c,%esp
f01038bc:	8b 75 08             	mov    0x8(%ebp),%esi
f01038bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01038c2:	c7 03 88 5c 10 f0    	movl   $0xf0105c88,(%ebx)
	info->eip_line = 0;
f01038c8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01038cf:	c7 43 08 88 5c 10 f0 	movl   $0xf0105c88,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01038d6:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01038dd:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01038e0:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01038e7:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01038ed:	77 21                	ja     f0103910 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01038ef:	a1 00 00 20 00       	mov    0x200000,%eax
f01038f4:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f01038f7:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01038fc:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103902:	89 7d c0             	mov    %edi,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0103905:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f010390b:	89 7d bc             	mov    %edi,-0x44(%ebp)
f010390e:	eb 1a                	jmp    f010392a <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103910:	c7 45 bc 43 00 11 f0 	movl   $0xf0110043,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103917:	c7 45 c0 e5 d5 10 f0 	movl   $0xf010d5e5,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010391e:	b8 e4 d5 10 f0       	mov    $0xf010d5e4,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103923:	c7 45 b8 b0 5e 10 f0 	movl   $0xf0105eb0,-0x48(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010392a:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010392d:	39 7d c0             	cmp    %edi,-0x40(%ebp)
f0103930:	0f 83 ad 01 00 00    	jae    f0103ae3 <debuginfo_eip+0x230>
f0103936:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010393a:	0f 85 aa 01 00 00    	jne    f0103aea <debuginfo_eip+0x237>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103940:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103947:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010394a:	29 f8                	sub    %edi,%eax
f010394c:	c1 f8 02             	sar    $0x2,%eax
f010394f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103955:	83 e8 01             	sub    $0x1,%eax
f0103958:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010395b:	56                   	push   %esi
f010395c:	6a 64                	push   $0x64
f010395e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103961:	89 c1                	mov    %eax,%ecx
f0103963:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103966:	89 f8                	mov    %edi,%eax
f0103968:	e8 50 fe ff ff       	call   f01037bd <stab_binsearch>
	if (lfile == 0)
f010396d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103970:	83 c4 08             	add    $0x8,%esp
f0103973:	85 c0                	test   %eax,%eax
f0103975:	0f 84 76 01 00 00    	je     f0103af1 <debuginfo_eip+0x23e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010397b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010397e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103981:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103984:	56                   	push   %esi
f0103985:	6a 24                	push   $0x24
f0103987:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010398a:	89 c1                	mov    %eax,%ecx
f010398c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010398f:	89 f8                	mov    %edi,%eax
f0103991:	e8 27 fe ff ff       	call   f01037bd <stab_binsearch>

	if (lfun <= rfun) {
f0103996:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103999:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010399c:	83 c4 08             	add    $0x8,%esp
f010399f:	39 c8                	cmp    %ecx,%eax
f01039a1:	7f 2e                	jg     f01039d1 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01039a3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01039a6:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01039a9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01039ac:	8b 12                	mov    (%edx),%edx
f01039ae:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01039b1:	2b 7d c0             	sub    -0x40(%ebp),%edi
f01039b4:	39 fa                	cmp    %edi,%edx
f01039b6:	73 06                	jae    f01039be <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01039b8:	03 55 c0             	add    -0x40(%ebp),%edx
f01039bb:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01039be:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01039c1:	8b 57 08             	mov    0x8(%edi),%edx
f01039c4:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01039c7:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01039c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01039cc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01039cf:	eb 0f                	jmp    f01039e0 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01039d1:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01039d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01039da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01039e0:	83 ec 08             	sub    $0x8,%esp
f01039e3:	6a 3a                	push   $0x3a
f01039e5:	ff 73 08             	pushl  0x8(%ebx)
f01039e8:	e8 05 09 00 00       	call   f01042f2 <strfind>
f01039ed:	2b 43 08             	sub    0x8(%ebx),%eax
f01039f0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	info->eip_file = stabstr + stabs[lfile].n_strx;
f01039f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039f6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01039f9:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01039fc:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01039ff:	03 0c 87             	add    (%edi,%eax,4),%ecx
f0103a02:	89 0b                	mov    %ecx,(%ebx)

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103a04:	83 c4 08             	add    $0x8,%esp
f0103a07:	56                   	push   %esi
f0103a08:	6a 44                	push   $0x44
f0103a0a:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103a0d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103a10:	89 fe                	mov    %edi,%esi
f0103a12:	89 f8                	mov    %edi,%eax
f0103a14:	e8 a4 fd ff ff       	call   f01037bd <stab_binsearch>
	if (lline > rline) {
f0103a19:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103a1f:	83 c4 10             	add    $0x10,%esp
f0103a22:	39 c2                	cmp    %eax,%edx
f0103a24:	0f 8f ce 00 00 00    	jg     f0103af8 <debuginfo_eip+0x245>
	    return -1;
	} else {
	    info->eip_line = stabs[rline].n_desc;
f0103a2a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103a2d:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0103a32:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a38:	89 d0                	mov    %edx,%eax
f0103a3a:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103a3d:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103a40:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103a44:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103a47:	eb 0a                	jmp    f0103a53 <debuginfo_eip+0x1a0>
f0103a49:	83 e8 01             	sub    $0x1,%eax
f0103a4c:	83 ea 0c             	sub    $0xc,%edx
f0103a4f:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0103a53:	39 c7                	cmp    %eax,%edi
f0103a55:	7e 05                	jle    f0103a5c <debuginfo_eip+0x1a9>
f0103a57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a5a:	eb 47                	jmp    f0103aa3 <debuginfo_eip+0x1f0>
	       && stabs[lline].n_type != N_SOL
f0103a5c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103a60:	80 f9 84             	cmp    $0x84,%cl
f0103a63:	75 0e                	jne    f0103a73 <debuginfo_eip+0x1c0>
f0103a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a68:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103a6c:	74 1c                	je     f0103a8a <debuginfo_eip+0x1d7>
f0103a6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a71:	eb 17                	jmp    f0103a8a <debuginfo_eip+0x1d7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103a73:	80 f9 64             	cmp    $0x64,%cl
f0103a76:	75 d1                	jne    f0103a49 <debuginfo_eip+0x196>
f0103a78:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103a7c:	74 cb                	je     f0103a49 <debuginfo_eip+0x196>
f0103a7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a81:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103a85:	74 03                	je     f0103a8a <debuginfo_eip+0x1d7>
f0103a87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103a8a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103a8d:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0103a90:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0103a93:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103a96:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103a99:	29 f0                	sub    %esi,%eax
f0103a9b:	39 c2                	cmp    %eax,%edx
f0103a9d:	73 04                	jae    f0103aa3 <debuginfo_eip+0x1f0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103a9f:	01 f2                	add    %esi,%edx
f0103aa1:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103aa3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103aa6:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103aa9:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103aae:	39 f2                	cmp    %esi,%edx
f0103ab0:	7d 52                	jge    f0103b04 <debuginfo_eip+0x251>
		for (lline = lfun + 1;
f0103ab2:	83 c2 01             	add    $0x1,%edx
f0103ab5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103ab8:	89 d0                	mov    %edx,%eax
f0103aba:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103abd:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103ac0:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103ac3:	eb 04                	jmp    f0103ac9 <debuginfo_eip+0x216>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103ac5:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103ac9:	39 c6                	cmp    %eax,%esi
f0103acb:	7e 32                	jle    f0103aff <debuginfo_eip+0x24c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103acd:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103ad1:	83 c0 01             	add    $0x1,%eax
f0103ad4:	83 c2 0c             	add    $0xc,%edx
f0103ad7:	80 f9 a0             	cmp    $0xa0,%cl
f0103ada:	74 e9                	je     f0103ac5 <debuginfo_eip+0x212>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103adc:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ae1:	eb 21                	jmp    f0103b04 <debuginfo_eip+0x251>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103ae3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ae8:	eb 1a                	jmp    f0103b04 <debuginfo_eip+0x251>
f0103aea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103aef:	eb 13                	jmp    f0103b04 <debuginfo_eip+0x251>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103af1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103af6:	eb 0c                	jmp    f0103b04 <debuginfo_eip+0x251>
	// Your code here.
	info->eip_file = stabstr + stabs[lfile].n_strx;

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
	    return -1;
f0103af8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103afd:	eb 05                	jmp    f0103b04 <debuginfo_eip+0x251>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b07:	5b                   	pop    %ebx
f0103b08:	5e                   	pop    %esi
f0103b09:	5f                   	pop    %edi
f0103b0a:	5d                   	pop    %ebp
f0103b0b:	c3                   	ret    

f0103b0c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103b0c:	55                   	push   %ebp
f0103b0d:	89 e5                	mov    %esp,%ebp
f0103b0f:	57                   	push   %edi
f0103b10:	56                   	push   %esi
f0103b11:	53                   	push   %ebx
f0103b12:	83 ec 1c             	sub    $0x1c,%esp
f0103b15:	89 c7                	mov    %eax,%edi
f0103b17:	89 d6                	mov    %edx,%esi
f0103b19:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b22:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103b28:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103b2d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103b30:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103b33:	39 d3                	cmp    %edx,%ebx
f0103b35:	72 05                	jb     f0103b3c <printnum+0x30>
f0103b37:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103b3a:	77 45                	ja     f0103b81 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103b3c:	83 ec 0c             	sub    $0xc,%esp
f0103b3f:	ff 75 18             	pushl  0x18(%ebp)
f0103b42:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b45:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103b48:	53                   	push   %ebx
f0103b49:	ff 75 10             	pushl  0x10(%ebp)
f0103b4c:	83 ec 08             	sub    $0x8,%esp
f0103b4f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103b52:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b55:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b58:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b5b:	e8 b0 09 00 00       	call   f0104510 <__udivdi3>
f0103b60:	83 c4 18             	add    $0x18,%esp
f0103b63:	52                   	push   %edx
f0103b64:	50                   	push   %eax
f0103b65:	89 f2                	mov    %esi,%edx
f0103b67:	89 f8                	mov    %edi,%eax
f0103b69:	e8 9e ff ff ff       	call   f0103b0c <printnum>
f0103b6e:	83 c4 20             	add    $0x20,%esp
f0103b71:	eb 18                	jmp    f0103b8b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103b73:	83 ec 08             	sub    $0x8,%esp
f0103b76:	56                   	push   %esi
f0103b77:	ff 75 18             	pushl  0x18(%ebp)
f0103b7a:	ff d7                	call   *%edi
f0103b7c:	83 c4 10             	add    $0x10,%esp
f0103b7f:	eb 03                	jmp    f0103b84 <printnum+0x78>
f0103b81:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103b84:	83 eb 01             	sub    $0x1,%ebx
f0103b87:	85 db                	test   %ebx,%ebx
f0103b89:	7f e8                	jg     f0103b73 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103b8b:	83 ec 08             	sub    $0x8,%esp
f0103b8e:	56                   	push   %esi
f0103b8f:	83 ec 04             	sub    $0x4,%esp
f0103b92:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103b95:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b98:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b9b:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b9e:	e8 9d 0a 00 00       	call   f0104640 <__umoddi3>
f0103ba3:	83 c4 14             	add    $0x14,%esp
f0103ba6:	0f be 80 92 5c 10 f0 	movsbl -0xfefa36e(%eax),%eax
f0103bad:	50                   	push   %eax
f0103bae:	ff d7                	call   *%edi
}
f0103bb0:	83 c4 10             	add    $0x10,%esp
f0103bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103bb6:	5b                   	pop    %ebx
f0103bb7:	5e                   	pop    %esi
f0103bb8:	5f                   	pop    %edi
f0103bb9:	5d                   	pop    %ebp
f0103bba:	c3                   	ret    

f0103bbb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103bbb:	55                   	push   %ebp
f0103bbc:	89 e5                	mov    %esp,%ebp
f0103bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103bc1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103bc5:	8b 10                	mov    (%eax),%edx
f0103bc7:	3b 50 04             	cmp    0x4(%eax),%edx
f0103bca:	73 0a                	jae    f0103bd6 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103bcc:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103bcf:	89 08                	mov    %ecx,(%eax)
f0103bd1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bd4:	88 02                	mov    %al,(%edx)
}
f0103bd6:	5d                   	pop    %ebp
f0103bd7:	c3                   	ret    

f0103bd8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103bd8:	55                   	push   %ebp
f0103bd9:	89 e5                	mov    %esp,%ebp
f0103bdb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103bde:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103be1:	50                   	push   %eax
f0103be2:	ff 75 10             	pushl  0x10(%ebp)
f0103be5:	ff 75 0c             	pushl  0xc(%ebp)
f0103be8:	ff 75 08             	pushl  0x8(%ebp)
f0103beb:	e8 05 00 00 00       	call   f0103bf5 <vprintfmt>
	va_end(ap);
}
f0103bf0:	83 c4 10             	add    $0x10,%esp
f0103bf3:	c9                   	leave  
f0103bf4:	c3                   	ret    

f0103bf5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103bf5:	55                   	push   %ebp
f0103bf6:	89 e5                	mov    %esp,%ebp
f0103bf8:	57                   	push   %edi
f0103bf9:	56                   	push   %esi
f0103bfa:	53                   	push   %ebx
f0103bfb:	83 ec 2c             	sub    $0x2c,%esp
f0103bfe:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c04:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103c07:	eb 12                	jmp    f0103c1b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103c09:	85 c0                	test   %eax,%eax
f0103c0b:	0f 84 36 04 00 00    	je     f0104047 <vprintfmt+0x452>
				return;
			putch(ch, putdat);
f0103c11:	83 ec 08             	sub    $0x8,%esp
f0103c14:	53                   	push   %ebx
f0103c15:	50                   	push   %eax
f0103c16:	ff d6                	call   *%esi
f0103c18:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103c1b:	83 c7 01             	add    $0x1,%edi
f0103c1e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103c22:	83 f8 25             	cmp    $0x25,%eax
f0103c25:	75 e2                	jne    f0103c09 <vprintfmt+0x14>
f0103c27:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103c2b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103c32:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103c39:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103c40:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103c45:	eb 07                	jmp    f0103c4e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c47:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103c4a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c4e:	8d 47 01             	lea    0x1(%edi),%eax
f0103c51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103c54:	0f b6 07             	movzbl (%edi),%eax
f0103c57:	0f b6 d0             	movzbl %al,%edx
f0103c5a:	83 e8 23             	sub    $0x23,%eax
f0103c5d:	3c 55                	cmp    $0x55,%al
f0103c5f:	0f 87 c7 03 00 00    	ja     f010402c <vprintfmt+0x437>
f0103c65:	0f b6 c0             	movzbl %al,%eax
f0103c68:	ff 24 85 20 5d 10 f0 	jmp    *-0xfefa2e0(,%eax,4)
f0103c6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103c72:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103c76:	eb d6                	jmp    f0103c4e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c80:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103c83:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103c86:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103c8a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103c8d:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103c90:	83 f9 09             	cmp    $0x9,%ecx
f0103c93:	77 3f                	ja     f0103cd4 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103c95:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103c98:	eb e9                	jmp    f0103c83 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103c9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c9d:	8b 00                	mov    (%eax),%eax
f0103c9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103ca2:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ca5:	8d 40 04             	lea    0x4(%eax),%eax
f0103ca8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103cae:	eb 2a                	jmp    f0103cda <vprintfmt+0xe5>
f0103cb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103cb3:	85 c0                	test   %eax,%eax
f0103cb5:	ba 00 00 00 00       	mov    $0x0,%edx
f0103cba:	0f 49 d0             	cmovns %eax,%edx
f0103cbd:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cc0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103cc3:	eb 89                	jmp    f0103c4e <vprintfmt+0x59>
f0103cc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103cc8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103ccf:	e9 7a ff ff ff       	jmp    f0103c4e <vprintfmt+0x59>
f0103cd4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103cd7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103cda:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103cde:	0f 89 6a ff ff ff    	jns    f0103c4e <vprintfmt+0x59>
				width = precision, precision = -1;
f0103ce4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ce7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103cea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103cf1:	e9 58 ff ff ff       	jmp    f0103c4e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103cf6:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cf9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103cfc:	e9 4d ff ff ff       	jmp    f0103c4e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103d01:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d04:	8d 78 04             	lea    0x4(%eax),%edi
f0103d07:	83 ec 08             	sub    $0x8,%esp
f0103d0a:	53                   	push   %ebx
f0103d0b:	ff 30                	pushl  (%eax)
f0103d0d:	ff d6                	call   *%esi
			break;
f0103d0f:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103d12:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103d18:	e9 fe fe ff ff       	jmp    f0103c1b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d20:	8d 78 04             	lea    0x4(%eax),%edi
f0103d23:	8b 00                	mov    (%eax),%eax
f0103d25:	99                   	cltd   
f0103d26:	31 d0                	xor    %edx,%eax
f0103d28:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103d2a:	83 f8 07             	cmp    $0x7,%eax
f0103d2d:	7f 0b                	jg     f0103d3a <vprintfmt+0x145>
f0103d2f:	8b 14 85 80 5e 10 f0 	mov    -0xfefa180(,%eax,4),%edx
f0103d36:	85 d2                	test   %edx,%edx
f0103d38:	75 1b                	jne    f0103d55 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0103d3a:	50                   	push   %eax
f0103d3b:	68 aa 5c 10 f0       	push   $0xf0105caa
f0103d40:	53                   	push   %ebx
f0103d41:	56                   	push   %esi
f0103d42:	e8 91 fe ff ff       	call   f0103bd8 <printfmt>
f0103d47:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d4a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103d50:	e9 c6 fe ff ff       	jmp    f0103c1b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103d55:	52                   	push   %edx
f0103d56:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0103d5b:	53                   	push   %ebx
f0103d5c:	56                   	push   %esi
f0103d5d:	e8 76 fe ff ff       	call   f0103bd8 <printfmt>
f0103d62:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d65:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d6b:	e9 ab fe ff ff       	jmp    f0103c1b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103d70:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d73:	83 c0 04             	add    $0x4,%eax
f0103d76:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103d79:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d7c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103d7e:	85 ff                	test   %edi,%edi
f0103d80:	b8 a3 5c 10 f0       	mov    $0xf0105ca3,%eax
f0103d85:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103d88:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103d8c:	0f 8e 94 00 00 00    	jle    f0103e26 <vprintfmt+0x231>
f0103d92:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103d96:	0f 84 98 00 00 00    	je     f0103e34 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103d9c:	83 ec 08             	sub    $0x8,%esp
f0103d9f:	ff 75 d0             	pushl  -0x30(%ebp)
f0103da2:	57                   	push   %edi
f0103da3:	e8 00 04 00 00       	call   f01041a8 <strnlen>
f0103da8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103dab:	29 c1                	sub    %eax,%ecx
f0103dad:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103db0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103db3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103db7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103dba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103dbd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103dbf:	eb 0f                	jmp    f0103dd0 <vprintfmt+0x1db>
					putch(padc, putdat);
f0103dc1:	83 ec 08             	sub    $0x8,%esp
f0103dc4:	53                   	push   %ebx
f0103dc5:	ff 75 e0             	pushl  -0x20(%ebp)
f0103dc8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103dca:	83 ef 01             	sub    $0x1,%edi
f0103dcd:	83 c4 10             	add    $0x10,%esp
f0103dd0:	85 ff                	test   %edi,%edi
f0103dd2:	7f ed                	jg     f0103dc1 <vprintfmt+0x1cc>
f0103dd4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103dd7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103dda:	85 c9                	test   %ecx,%ecx
f0103ddc:	b8 00 00 00 00       	mov    $0x0,%eax
f0103de1:	0f 49 c1             	cmovns %ecx,%eax
f0103de4:	29 c1                	sub    %eax,%ecx
f0103de6:	89 75 08             	mov    %esi,0x8(%ebp)
f0103de9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103dec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103def:	89 cb                	mov    %ecx,%ebx
f0103df1:	eb 4d                	jmp    f0103e40 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103df3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103df7:	74 1b                	je     f0103e14 <vprintfmt+0x21f>
f0103df9:	0f be c0             	movsbl %al,%eax
f0103dfc:	83 e8 20             	sub    $0x20,%eax
f0103dff:	83 f8 5e             	cmp    $0x5e,%eax
f0103e02:	76 10                	jbe    f0103e14 <vprintfmt+0x21f>
					putch('?', putdat);
f0103e04:	83 ec 08             	sub    $0x8,%esp
f0103e07:	ff 75 0c             	pushl  0xc(%ebp)
f0103e0a:	6a 3f                	push   $0x3f
f0103e0c:	ff 55 08             	call   *0x8(%ebp)
f0103e0f:	83 c4 10             	add    $0x10,%esp
f0103e12:	eb 0d                	jmp    f0103e21 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0103e14:	83 ec 08             	sub    $0x8,%esp
f0103e17:	ff 75 0c             	pushl  0xc(%ebp)
f0103e1a:	52                   	push   %edx
f0103e1b:	ff 55 08             	call   *0x8(%ebp)
f0103e1e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e21:	83 eb 01             	sub    $0x1,%ebx
f0103e24:	eb 1a                	jmp    f0103e40 <vprintfmt+0x24b>
f0103e26:	89 75 08             	mov    %esi,0x8(%ebp)
f0103e29:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103e2c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103e2f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103e32:	eb 0c                	jmp    f0103e40 <vprintfmt+0x24b>
f0103e34:	89 75 08             	mov    %esi,0x8(%ebp)
f0103e37:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103e3a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103e3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103e40:	83 c7 01             	add    $0x1,%edi
f0103e43:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103e47:	0f be d0             	movsbl %al,%edx
f0103e4a:	85 d2                	test   %edx,%edx
f0103e4c:	74 23                	je     f0103e71 <vprintfmt+0x27c>
f0103e4e:	85 f6                	test   %esi,%esi
f0103e50:	78 a1                	js     f0103df3 <vprintfmt+0x1fe>
f0103e52:	83 ee 01             	sub    $0x1,%esi
f0103e55:	79 9c                	jns    f0103df3 <vprintfmt+0x1fe>
f0103e57:	89 df                	mov    %ebx,%edi
f0103e59:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e5f:	eb 18                	jmp    f0103e79 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103e61:	83 ec 08             	sub    $0x8,%esp
f0103e64:	53                   	push   %ebx
f0103e65:	6a 20                	push   $0x20
f0103e67:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103e69:	83 ef 01             	sub    $0x1,%edi
f0103e6c:	83 c4 10             	add    $0x10,%esp
f0103e6f:	eb 08                	jmp    f0103e79 <vprintfmt+0x284>
f0103e71:	89 df                	mov    %ebx,%edi
f0103e73:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e79:	85 ff                	test   %edi,%edi
f0103e7b:	7f e4                	jg     f0103e61 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103e7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103e80:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e86:	e9 90 fd ff ff       	jmp    f0103c1b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103e8b:	83 f9 01             	cmp    $0x1,%ecx
f0103e8e:	7e 19                	jle    f0103ea9 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0103e90:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e93:	8b 50 04             	mov    0x4(%eax),%edx
f0103e96:	8b 00                	mov    (%eax),%eax
f0103e98:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e9b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103e9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ea1:	8d 40 08             	lea    0x8(%eax),%eax
f0103ea4:	89 45 14             	mov    %eax,0x14(%ebp)
f0103ea7:	eb 38                	jmp    f0103ee1 <vprintfmt+0x2ec>
	else if (lflag)
f0103ea9:	85 c9                	test   %ecx,%ecx
f0103eab:	74 1b                	je     f0103ec8 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0103ead:	8b 45 14             	mov    0x14(%ebp),%eax
f0103eb0:	8b 00                	mov    (%eax),%eax
f0103eb2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103eb5:	89 c1                	mov    %eax,%ecx
f0103eb7:	c1 f9 1f             	sar    $0x1f,%ecx
f0103eba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103ebd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ec0:	8d 40 04             	lea    0x4(%eax),%eax
f0103ec3:	89 45 14             	mov    %eax,0x14(%ebp)
f0103ec6:	eb 19                	jmp    f0103ee1 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0103ec8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ecb:	8b 00                	mov    (%eax),%eax
f0103ecd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103ed0:	89 c1                	mov    %eax,%ecx
f0103ed2:	c1 f9 1f             	sar    $0x1f,%ecx
f0103ed5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103ed8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103edb:	8d 40 04             	lea    0x4(%eax),%eax
f0103ede:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103ee1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ee4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103ee7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103eec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103ef0:	0f 89 02 01 00 00    	jns    f0103ff8 <vprintfmt+0x403>
				putch('-', putdat);
f0103ef6:	83 ec 08             	sub    $0x8,%esp
f0103ef9:	53                   	push   %ebx
f0103efa:	6a 2d                	push   $0x2d
f0103efc:	ff d6                	call   *%esi
				num = -(long long) num;
f0103efe:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103f01:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103f04:	f7 da                	neg    %edx
f0103f06:	83 d1 00             	adc    $0x0,%ecx
f0103f09:	f7 d9                	neg    %ecx
f0103f0b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103f0e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f13:	e9 e0 00 00 00       	jmp    f0103ff8 <vprintfmt+0x403>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103f18:	83 f9 01             	cmp    $0x1,%ecx
f0103f1b:	7e 18                	jle    f0103f35 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0103f1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f20:	8b 10                	mov    (%eax),%edx
f0103f22:	8b 48 04             	mov    0x4(%eax),%ecx
f0103f25:	8d 40 08             	lea    0x8(%eax),%eax
f0103f28:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103f2b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f30:	e9 c3 00 00 00       	jmp    f0103ff8 <vprintfmt+0x403>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0103f35:	85 c9                	test   %ecx,%ecx
f0103f37:	74 1a                	je     f0103f53 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0103f39:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f3c:	8b 10                	mov    (%eax),%edx
f0103f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103f43:	8d 40 04             	lea    0x4(%eax),%eax
f0103f46:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103f49:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f4e:	e9 a5 00 00 00       	jmp    f0103ff8 <vprintfmt+0x403>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0103f53:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f56:	8b 10                	mov    (%eax),%edx
f0103f58:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103f5d:	8d 40 04             	lea    0x4(%eax),%eax
f0103f60:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103f63:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f68:	e9 8b 00 00 00       	jmp    f0103ff8 <vprintfmt+0x403>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('0', putdat);
			num = (unsigned long long)
f0103f6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f70:	8b 10                	mov    (%eax),%edx
f0103f72:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0103f77:	8d 40 04             	lea    0x4(%eax),%eax
f0103f7a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0103f7d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0103f82:	eb 74                	jmp    f0103ff8 <vprintfmt+0x403>

		// pointer
		case 'p':
			putch('0', putdat);
f0103f84:	83 ec 08             	sub    $0x8,%esp
f0103f87:	53                   	push   %ebx
f0103f88:	6a 30                	push   $0x30
f0103f8a:	ff d6                	call   *%esi
			putch('x', putdat);
f0103f8c:	83 c4 08             	add    $0x8,%esp
f0103f8f:	53                   	push   %ebx
f0103f90:	6a 78                	push   $0x78
f0103f92:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103f94:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f97:	8b 10                	mov    (%eax),%edx
f0103f99:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103f9e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103fa1:	8d 40 04             	lea    0x4(%eax),%eax
f0103fa4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103fa7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103fac:	eb 4a                	jmp    f0103ff8 <vprintfmt+0x403>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103fae:	83 f9 01             	cmp    $0x1,%ecx
f0103fb1:	7e 15                	jle    f0103fc8 <vprintfmt+0x3d3>
		return va_arg(*ap, unsigned long long);
f0103fb3:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fb6:	8b 10                	mov    (%eax),%edx
f0103fb8:	8b 48 04             	mov    0x4(%eax),%ecx
f0103fbb:	8d 40 08             	lea    0x8(%eax),%eax
f0103fbe:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103fc1:	b8 10 00 00 00       	mov    $0x10,%eax
f0103fc6:	eb 30                	jmp    f0103ff8 <vprintfmt+0x403>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0103fc8:	85 c9                	test   %ecx,%ecx
f0103fca:	74 17                	je     f0103fe3 <vprintfmt+0x3ee>
		return va_arg(*ap, unsigned long);
f0103fcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fcf:	8b 10                	mov    (%eax),%edx
f0103fd1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103fd6:	8d 40 04             	lea    0x4(%eax),%eax
f0103fd9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103fdc:	b8 10 00 00 00       	mov    $0x10,%eax
f0103fe1:	eb 15                	jmp    f0103ff8 <vprintfmt+0x403>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0103fe3:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fe6:	8b 10                	mov    (%eax),%edx
f0103fe8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103fed:	8d 40 04             	lea    0x4(%eax),%eax
f0103ff0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103ff3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103ff8:	83 ec 0c             	sub    $0xc,%esp
f0103ffb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103fff:	57                   	push   %edi
f0104000:	ff 75 e0             	pushl  -0x20(%ebp)
f0104003:	50                   	push   %eax
f0104004:	51                   	push   %ecx
f0104005:	52                   	push   %edx
f0104006:	89 da                	mov    %ebx,%edx
f0104008:	89 f0                	mov    %esi,%eax
f010400a:	e8 fd fa ff ff       	call   f0103b0c <printnum>
			break;
f010400f:	83 c4 20             	add    $0x20,%esp
f0104012:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104015:	e9 01 fc ff ff       	jmp    f0103c1b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010401a:	83 ec 08             	sub    $0x8,%esp
f010401d:	53                   	push   %ebx
f010401e:	52                   	push   %edx
f010401f:	ff d6                	call   *%esi
			break;
f0104021:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104024:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104027:	e9 ef fb ff ff       	jmp    f0103c1b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010402c:	83 ec 08             	sub    $0x8,%esp
f010402f:	53                   	push   %ebx
f0104030:	6a 25                	push   $0x25
f0104032:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104034:	83 c4 10             	add    $0x10,%esp
f0104037:	eb 03                	jmp    f010403c <vprintfmt+0x447>
f0104039:	83 ef 01             	sub    $0x1,%edi
f010403c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104040:	75 f7                	jne    f0104039 <vprintfmt+0x444>
f0104042:	e9 d4 fb ff ff       	jmp    f0103c1b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104047:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010404a:	5b                   	pop    %ebx
f010404b:	5e                   	pop    %esi
f010404c:	5f                   	pop    %edi
f010404d:	5d                   	pop    %ebp
f010404e:	c3                   	ret    

f010404f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010404f:	55                   	push   %ebp
f0104050:	89 e5                	mov    %esp,%ebp
f0104052:	83 ec 18             	sub    $0x18,%esp
f0104055:	8b 45 08             	mov    0x8(%ebp),%eax
f0104058:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010405b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010405e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104062:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104065:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010406c:	85 c0                	test   %eax,%eax
f010406e:	74 26                	je     f0104096 <vsnprintf+0x47>
f0104070:	85 d2                	test   %edx,%edx
f0104072:	7e 22                	jle    f0104096 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104074:	ff 75 14             	pushl  0x14(%ebp)
f0104077:	ff 75 10             	pushl  0x10(%ebp)
f010407a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010407d:	50                   	push   %eax
f010407e:	68 bb 3b 10 f0       	push   $0xf0103bbb
f0104083:	e8 6d fb ff ff       	call   f0103bf5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104088:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010408b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010408e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104091:	83 c4 10             	add    $0x10,%esp
f0104094:	eb 05                	jmp    f010409b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104096:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010409b:	c9                   	leave  
f010409c:	c3                   	ret    

f010409d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010409d:	55                   	push   %ebp
f010409e:	89 e5                	mov    %esp,%ebp
f01040a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01040a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01040a6:	50                   	push   %eax
f01040a7:	ff 75 10             	pushl  0x10(%ebp)
f01040aa:	ff 75 0c             	pushl  0xc(%ebp)
f01040ad:	ff 75 08             	pushl  0x8(%ebp)
f01040b0:	e8 9a ff ff ff       	call   f010404f <vsnprintf>
	va_end(ap);

	return rc;
}
f01040b5:	c9                   	leave  
f01040b6:	c3                   	ret    

f01040b7 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01040b7:	55                   	push   %ebp
f01040b8:	89 e5                	mov    %esp,%ebp
f01040ba:	57                   	push   %edi
f01040bb:	56                   	push   %esi
f01040bc:	53                   	push   %ebx
f01040bd:	83 ec 0c             	sub    $0xc,%esp
f01040c0:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01040c3:	85 c0                	test   %eax,%eax
f01040c5:	74 11                	je     f01040d8 <readline+0x21>
		cprintf("%s", prompt);
f01040c7:	83 ec 08             	sub    $0x8,%esp
f01040ca:	50                   	push   %eax
f01040cb:	68 cc 4c 10 f0       	push   $0xf0104ccc
f01040d0:	e8 79 ee ff ff       	call   f0102f4e <cprintf>
f01040d5:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01040d8:	83 ec 0c             	sub    $0xc,%esp
f01040db:	6a 00                	push   $0x0
f01040dd:	e8 46 c5 ff ff       	call   f0100628 <iscons>
f01040e2:	89 c7                	mov    %eax,%edi
f01040e4:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01040e7:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01040ec:	e8 26 c5 ff ff       	call   f0100617 <getchar>
f01040f1:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01040f3:	85 c0                	test   %eax,%eax
f01040f5:	79 18                	jns    f010410f <readline+0x58>
			cprintf("read error: %e\n", c);
f01040f7:	83 ec 08             	sub    $0x8,%esp
f01040fa:	50                   	push   %eax
f01040fb:	68 a0 5e 10 f0       	push   $0xf0105ea0
f0104100:	e8 49 ee ff ff       	call   f0102f4e <cprintf>
			return NULL;
f0104105:	83 c4 10             	add    $0x10,%esp
f0104108:	b8 00 00 00 00       	mov    $0x0,%eax
f010410d:	eb 79                	jmp    f0104188 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010410f:	83 f8 08             	cmp    $0x8,%eax
f0104112:	0f 94 c2             	sete   %dl
f0104115:	83 f8 7f             	cmp    $0x7f,%eax
f0104118:	0f 94 c0             	sete   %al
f010411b:	08 c2                	or     %al,%dl
f010411d:	74 1a                	je     f0104139 <readline+0x82>
f010411f:	85 f6                	test   %esi,%esi
f0104121:	7e 16                	jle    f0104139 <readline+0x82>
			if (echoing)
f0104123:	85 ff                	test   %edi,%edi
f0104125:	74 0d                	je     f0104134 <readline+0x7d>
				cputchar('\b');
f0104127:	83 ec 0c             	sub    $0xc,%esp
f010412a:	6a 08                	push   $0x8
f010412c:	e8 d6 c4 ff ff       	call   f0100607 <cputchar>
f0104131:	83 c4 10             	add    $0x10,%esp
			i--;
f0104134:	83 ee 01             	sub    $0x1,%esi
f0104137:	eb b3                	jmp    f01040ec <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104139:	83 fb 1f             	cmp    $0x1f,%ebx
f010413c:	7e 23                	jle    f0104161 <readline+0xaa>
f010413e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104144:	7f 1b                	jg     f0104161 <readline+0xaa>
			if (echoing)
f0104146:	85 ff                	test   %edi,%edi
f0104148:	74 0c                	je     f0104156 <readline+0x9f>
				cputchar(c);
f010414a:	83 ec 0c             	sub    $0xc,%esp
f010414d:	53                   	push   %ebx
f010414e:	e8 b4 c4 ff ff       	call   f0100607 <cputchar>
f0104153:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104156:	88 9e 00 d7 17 f0    	mov    %bl,-0xfe82900(%esi)
f010415c:	8d 76 01             	lea    0x1(%esi),%esi
f010415f:	eb 8b                	jmp    f01040ec <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104161:	83 fb 0a             	cmp    $0xa,%ebx
f0104164:	74 05                	je     f010416b <readline+0xb4>
f0104166:	83 fb 0d             	cmp    $0xd,%ebx
f0104169:	75 81                	jne    f01040ec <readline+0x35>
			if (echoing)
f010416b:	85 ff                	test   %edi,%edi
f010416d:	74 0d                	je     f010417c <readline+0xc5>
				cputchar('\n');
f010416f:	83 ec 0c             	sub    $0xc,%esp
f0104172:	6a 0a                	push   $0xa
f0104174:	e8 8e c4 ff ff       	call   f0100607 <cputchar>
f0104179:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010417c:	c6 86 00 d7 17 f0 00 	movb   $0x0,-0xfe82900(%esi)
			return buf;
f0104183:	b8 00 d7 17 f0       	mov    $0xf017d700,%eax
		}
	}
}
f0104188:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010418b:	5b                   	pop    %ebx
f010418c:	5e                   	pop    %esi
f010418d:	5f                   	pop    %edi
f010418e:	5d                   	pop    %ebp
f010418f:	c3                   	ret    

f0104190 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104190:	55                   	push   %ebp
f0104191:	89 e5                	mov    %esp,%ebp
f0104193:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104196:	b8 00 00 00 00       	mov    $0x0,%eax
f010419b:	eb 03                	jmp    f01041a0 <strlen+0x10>
		n++;
f010419d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01041a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01041a4:	75 f7                	jne    f010419d <strlen+0xd>
		n++;
	return n;
}
f01041a6:	5d                   	pop    %ebp
f01041a7:	c3                   	ret    

f01041a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01041a8:	55                   	push   %ebp
f01041a9:	89 e5                	mov    %esp,%ebp
f01041ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01041ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01041b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01041b6:	eb 03                	jmp    f01041bb <strnlen+0x13>
		n++;
f01041b8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01041bb:	39 c2                	cmp    %eax,%edx
f01041bd:	74 08                	je     f01041c7 <strnlen+0x1f>
f01041bf:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01041c3:	75 f3                	jne    f01041b8 <strnlen+0x10>
f01041c5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01041c7:	5d                   	pop    %ebp
f01041c8:	c3                   	ret    

f01041c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01041c9:	55                   	push   %ebp
f01041ca:	89 e5                	mov    %esp,%ebp
f01041cc:	53                   	push   %ebx
f01041cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01041d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01041d3:	89 c2                	mov    %eax,%edx
f01041d5:	83 c2 01             	add    $0x1,%edx
f01041d8:	83 c1 01             	add    $0x1,%ecx
f01041db:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01041df:	88 5a ff             	mov    %bl,-0x1(%edx)
f01041e2:	84 db                	test   %bl,%bl
f01041e4:	75 ef                	jne    f01041d5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01041e6:	5b                   	pop    %ebx
f01041e7:	5d                   	pop    %ebp
f01041e8:	c3                   	ret    

f01041e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01041e9:	55                   	push   %ebp
f01041ea:	89 e5                	mov    %esp,%ebp
f01041ec:	53                   	push   %ebx
f01041ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01041f0:	53                   	push   %ebx
f01041f1:	e8 9a ff ff ff       	call   f0104190 <strlen>
f01041f6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01041f9:	ff 75 0c             	pushl  0xc(%ebp)
f01041fc:	01 d8                	add    %ebx,%eax
f01041fe:	50                   	push   %eax
f01041ff:	e8 c5 ff ff ff       	call   f01041c9 <strcpy>
	return dst;
}
f0104204:	89 d8                	mov    %ebx,%eax
f0104206:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104209:	c9                   	leave  
f010420a:	c3                   	ret    

f010420b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010420b:	55                   	push   %ebp
f010420c:	89 e5                	mov    %esp,%ebp
f010420e:	56                   	push   %esi
f010420f:	53                   	push   %ebx
f0104210:	8b 75 08             	mov    0x8(%ebp),%esi
f0104213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104216:	89 f3                	mov    %esi,%ebx
f0104218:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010421b:	89 f2                	mov    %esi,%edx
f010421d:	eb 0f                	jmp    f010422e <strncpy+0x23>
		*dst++ = *src;
f010421f:	83 c2 01             	add    $0x1,%edx
f0104222:	0f b6 01             	movzbl (%ecx),%eax
f0104225:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104228:	80 39 01             	cmpb   $0x1,(%ecx)
f010422b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010422e:	39 da                	cmp    %ebx,%edx
f0104230:	75 ed                	jne    f010421f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104232:	89 f0                	mov    %esi,%eax
f0104234:	5b                   	pop    %ebx
f0104235:	5e                   	pop    %esi
f0104236:	5d                   	pop    %ebp
f0104237:	c3                   	ret    

f0104238 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104238:	55                   	push   %ebp
f0104239:	89 e5                	mov    %esp,%ebp
f010423b:	56                   	push   %esi
f010423c:	53                   	push   %ebx
f010423d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104243:	8b 55 10             	mov    0x10(%ebp),%edx
f0104246:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104248:	85 d2                	test   %edx,%edx
f010424a:	74 21                	je     f010426d <strlcpy+0x35>
f010424c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104250:	89 f2                	mov    %esi,%edx
f0104252:	eb 09                	jmp    f010425d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104254:	83 c2 01             	add    $0x1,%edx
f0104257:	83 c1 01             	add    $0x1,%ecx
f010425a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010425d:	39 c2                	cmp    %eax,%edx
f010425f:	74 09                	je     f010426a <strlcpy+0x32>
f0104261:	0f b6 19             	movzbl (%ecx),%ebx
f0104264:	84 db                	test   %bl,%bl
f0104266:	75 ec                	jne    f0104254 <strlcpy+0x1c>
f0104268:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010426a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010426d:	29 f0                	sub    %esi,%eax
}
f010426f:	5b                   	pop    %ebx
f0104270:	5e                   	pop    %esi
f0104271:	5d                   	pop    %ebp
f0104272:	c3                   	ret    

f0104273 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104273:	55                   	push   %ebp
f0104274:	89 e5                	mov    %esp,%ebp
f0104276:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104279:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010427c:	eb 06                	jmp    f0104284 <strcmp+0x11>
		p++, q++;
f010427e:	83 c1 01             	add    $0x1,%ecx
f0104281:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104284:	0f b6 01             	movzbl (%ecx),%eax
f0104287:	84 c0                	test   %al,%al
f0104289:	74 04                	je     f010428f <strcmp+0x1c>
f010428b:	3a 02                	cmp    (%edx),%al
f010428d:	74 ef                	je     f010427e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010428f:	0f b6 c0             	movzbl %al,%eax
f0104292:	0f b6 12             	movzbl (%edx),%edx
f0104295:	29 d0                	sub    %edx,%eax
}
f0104297:	5d                   	pop    %ebp
f0104298:	c3                   	ret    

f0104299 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104299:	55                   	push   %ebp
f010429a:	89 e5                	mov    %esp,%ebp
f010429c:	53                   	push   %ebx
f010429d:	8b 45 08             	mov    0x8(%ebp),%eax
f01042a0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01042a3:	89 c3                	mov    %eax,%ebx
f01042a5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01042a8:	eb 06                	jmp    f01042b0 <strncmp+0x17>
		n--, p++, q++;
f01042aa:	83 c0 01             	add    $0x1,%eax
f01042ad:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01042b0:	39 d8                	cmp    %ebx,%eax
f01042b2:	74 15                	je     f01042c9 <strncmp+0x30>
f01042b4:	0f b6 08             	movzbl (%eax),%ecx
f01042b7:	84 c9                	test   %cl,%cl
f01042b9:	74 04                	je     f01042bf <strncmp+0x26>
f01042bb:	3a 0a                	cmp    (%edx),%cl
f01042bd:	74 eb                	je     f01042aa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01042bf:	0f b6 00             	movzbl (%eax),%eax
f01042c2:	0f b6 12             	movzbl (%edx),%edx
f01042c5:	29 d0                	sub    %edx,%eax
f01042c7:	eb 05                	jmp    f01042ce <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01042c9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01042ce:	5b                   	pop    %ebx
f01042cf:	5d                   	pop    %ebp
f01042d0:	c3                   	ret    

f01042d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01042d1:	55                   	push   %ebp
f01042d2:	89 e5                	mov    %esp,%ebp
f01042d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01042d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01042db:	eb 07                	jmp    f01042e4 <strchr+0x13>
		if (*s == c)
f01042dd:	38 ca                	cmp    %cl,%dl
f01042df:	74 0f                	je     f01042f0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01042e1:	83 c0 01             	add    $0x1,%eax
f01042e4:	0f b6 10             	movzbl (%eax),%edx
f01042e7:	84 d2                	test   %dl,%dl
f01042e9:	75 f2                	jne    f01042dd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01042eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042f0:	5d                   	pop    %ebp
f01042f1:	c3                   	ret    

f01042f2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01042f2:	55                   	push   %ebp
f01042f3:	89 e5                	mov    %esp,%ebp
f01042f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01042f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01042fc:	eb 03                	jmp    f0104301 <strfind+0xf>
f01042fe:	83 c0 01             	add    $0x1,%eax
f0104301:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104304:	38 ca                	cmp    %cl,%dl
f0104306:	74 04                	je     f010430c <strfind+0x1a>
f0104308:	84 d2                	test   %dl,%dl
f010430a:	75 f2                	jne    f01042fe <strfind+0xc>
			break;
	return (char *) s;
}
f010430c:	5d                   	pop    %ebp
f010430d:	c3                   	ret    

f010430e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010430e:	55                   	push   %ebp
f010430f:	89 e5                	mov    %esp,%ebp
f0104311:	57                   	push   %edi
f0104312:	56                   	push   %esi
f0104313:	53                   	push   %ebx
f0104314:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104317:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010431a:	85 c9                	test   %ecx,%ecx
f010431c:	74 36                	je     f0104354 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010431e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104324:	75 28                	jne    f010434e <memset+0x40>
f0104326:	f6 c1 03             	test   $0x3,%cl
f0104329:	75 23                	jne    f010434e <memset+0x40>
		c &= 0xFF;
f010432b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010432f:	89 d3                	mov    %edx,%ebx
f0104331:	c1 e3 08             	shl    $0x8,%ebx
f0104334:	89 d6                	mov    %edx,%esi
f0104336:	c1 e6 18             	shl    $0x18,%esi
f0104339:	89 d0                	mov    %edx,%eax
f010433b:	c1 e0 10             	shl    $0x10,%eax
f010433e:	09 f0                	or     %esi,%eax
f0104340:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0104342:	89 d8                	mov    %ebx,%eax
f0104344:	09 d0                	or     %edx,%eax
f0104346:	c1 e9 02             	shr    $0x2,%ecx
f0104349:	fc                   	cld    
f010434a:	f3 ab                	rep stos %eax,%es:(%edi)
f010434c:	eb 06                	jmp    f0104354 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010434e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104351:	fc                   	cld    
f0104352:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104354:	89 f8                	mov    %edi,%eax
f0104356:	5b                   	pop    %ebx
f0104357:	5e                   	pop    %esi
f0104358:	5f                   	pop    %edi
f0104359:	5d                   	pop    %ebp
f010435a:	c3                   	ret    

f010435b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010435b:	55                   	push   %ebp
f010435c:	89 e5                	mov    %esp,%ebp
f010435e:	57                   	push   %edi
f010435f:	56                   	push   %esi
f0104360:	8b 45 08             	mov    0x8(%ebp),%eax
f0104363:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104366:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104369:	39 c6                	cmp    %eax,%esi
f010436b:	73 35                	jae    f01043a2 <memmove+0x47>
f010436d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104370:	39 d0                	cmp    %edx,%eax
f0104372:	73 2e                	jae    f01043a2 <memmove+0x47>
		s += n;
		d += n;
f0104374:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104377:	89 d6                	mov    %edx,%esi
f0104379:	09 fe                	or     %edi,%esi
f010437b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104381:	75 13                	jne    f0104396 <memmove+0x3b>
f0104383:	f6 c1 03             	test   $0x3,%cl
f0104386:	75 0e                	jne    f0104396 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0104388:	83 ef 04             	sub    $0x4,%edi
f010438b:	8d 72 fc             	lea    -0x4(%edx),%esi
f010438e:	c1 e9 02             	shr    $0x2,%ecx
f0104391:	fd                   	std    
f0104392:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104394:	eb 09                	jmp    f010439f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104396:	83 ef 01             	sub    $0x1,%edi
f0104399:	8d 72 ff             	lea    -0x1(%edx),%esi
f010439c:	fd                   	std    
f010439d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010439f:	fc                   	cld    
f01043a0:	eb 1d                	jmp    f01043bf <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01043a2:	89 f2                	mov    %esi,%edx
f01043a4:	09 c2                	or     %eax,%edx
f01043a6:	f6 c2 03             	test   $0x3,%dl
f01043a9:	75 0f                	jne    f01043ba <memmove+0x5f>
f01043ab:	f6 c1 03             	test   $0x3,%cl
f01043ae:	75 0a                	jne    f01043ba <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01043b0:	c1 e9 02             	shr    $0x2,%ecx
f01043b3:	89 c7                	mov    %eax,%edi
f01043b5:	fc                   	cld    
f01043b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01043b8:	eb 05                	jmp    f01043bf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01043ba:	89 c7                	mov    %eax,%edi
f01043bc:	fc                   	cld    
f01043bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01043bf:	5e                   	pop    %esi
f01043c0:	5f                   	pop    %edi
f01043c1:	5d                   	pop    %ebp
f01043c2:	c3                   	ret    

f01043c3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01043c3:	55                   	push   %ebp
f01043c4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01043c6:	ff 75 10             	pushl  0x10(%ebp)
f01043c9:	ff 75 0c             	pushl  0xc(%ebp)
f01043cc:	ff 75 08             	pushl  0x8(%ebp)
f01043cf:	e8 87 ff ff ff       	call   f010435b <memmove>
}
f01043d4:	c9                   	leave  
f01043d5:	c3                   	ret    

f01043d6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01043d6:	55                   	push   %ebp
f01043d7:	89 e5                	mov    %esp,%ebp
f01043d9:	56                   	push   %esi
f01043da:	53                   	push   %ebx
f01043db:	8b 45 08             	mov    0x8(%ebp),%eax
f01043de:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043e1:	89 c6                	mov    %eax,%esi
f01043e3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01043e6:	eb 1a                	jmp    f0104402 <memcmp+0x2c>
		if (*s1 != *s2)
f01043e8:	0f b6 08             	movzbl (%eax),%ecx
f01043eb:	0f b6 1a             	movzbl (%edx),%ebx
f01043ee:	38 d9                	cmp    %bl,%cl
f01043f0:	74 0a                	je     f01043fc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01043f2:	0f b6 c1             	movzbl %cl,%eax
f01043f5:	0f b6 db             	movzbl %bl,%ebx
f01043f8:	29 d8                	sub    %ebx,%eax
f01043fa:	eb 0f                	jmp    f010440b <memcmp+0x35>
		s1++, s2++;
f01043fc:	83 c0 01             	add    $0x1,%eax
f01043ff:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104402:	39 f0                	cmp    %esi,%eax
f0104404:	75 e2                	jne    f01043e8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104406:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010440b:	5b                   	pop    %ebx
f010440c:	5e                   	pop    %esi
f010440d:	5d                   	pop    %ebp
f010440e:	c3                   	ret    

f010440f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010440f:	55                   	push   %ebp
f0104410:	89 e5                	mov    %esp,%ebp
f0104412:	53                   	push   %ebx
f0104413:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104416:	89 c1                	mov    %eax,%ecx
f0104418:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010441b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010441f:	eb 0a                	jmp    f010442b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104421:	0f b6 10             	movzbl (%eax),%edx
f0104424:	39 da                	cmp    %ebx,%edx
f0104426:	74 07                	je     f010442f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104428:	83 c0 01             	add    $0x1,%eax
f010442b:	39 c8                	cmp    %ecx,%eax
f010442d:	72 f2                	jb     f0104421 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010442f:	5b                   	pop    %ebx
f0104430:	5d                   	pop    %ebp
f0104431:	c3                   	ret    

f0104432 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104432:	55                   	push   %ebp
f0104433:	89 e5                	mov    %esp,%ebp
f0104435:	57                   	push   %edi
f0104436:	56                   	push   %esi
f0104437:	53                   	push   %ebx
f0104438:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010443b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010443e:	eb 03                	jmp    f0104443 <strtol+0x11>
		s++;
f0104440:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104443:	0f b6 01             	movzbl (%ecx),%eax
f0104446:	3c 20                	cmp    $0x20,%al
f0104448:	74 f6                	je     f0104440 <strtol+0xe>
f010444a:	3c 09                	cmp    $0x9,%al
f010444c:	74 f2                	je     f0104440 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010444e:	3c 2b                	cmp    $0x2b,%al
f0104450:	75 0a                	jne    f010445c <strtol+0x2a>
		s++;
f0104452:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104455:	bf 00 00 00 00       	mov    $0x0,%edi
f010445a:	eb 11                	jmp    f010446d <strtol+0x3b>
f010445c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104461:	3c 2d                	cmp    $0x2d,%al
f0104463:	75 08                	jne    f010446d <strtol+0x3b>
		s++, neg = 1;
f0104465:	83 c1 01             	add    $0x1,%ecx
f0104468:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010446d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104473:	75 15                	jne    f010448a <strtol+0x58>
f0104475:	80 39 30             	cmpb   $0x30,(%ecx)
f0104478:	75 10                	jne    f010448a <strtol+0x58>
f010447a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010447e:	75 7c                	jne    f01044fc <strtol+0xca>
		s += 2, base = 16;
f0104480:	83 c1 02             	add    $0x2,%ecx
f0104483:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104488:	eb 16                	jmp    f01044a0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010448a:	85 db                	test   %ebx,%ebx
f010448c:	75 12                	jne    f01044a0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010448e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104493:	80 39 30             	cmpb   $0x30,(%ecx)
f0104496:	75 08                	jne    f01044a0 <strtol+0x6e>
		s++, base = 8;
f0104498:	83 c1 01             	add    $0x1,%ecx
f010449b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01044a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01044a5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01044a8:	0f b6 11             	movzbl (%ecx),%edx
f01044ab:	8d 72 d0             	lea    -0x30(%edx),%esi
f01044ae:	89 f3                	mov    %esi,%ebx
f01044b0:	80 fb 09             	cmp    $0x9,%bl
f01044b3:	77 08                	ja     f01044bd <strtol+0x8b>
			dig = *s - '0';
f01044b5:	0f be d2             	movsbl %dl,%edx
f01044b8:	83 ea 30             	sub    $0x30,%edx
f01044bb:	eb 22                	jmp    f01044df <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01044bd:	8d 72 9f             	lea    -0x61(%edx),%esi
f01044c0:	89 f3                	mov    %esi,%ebx
f01044c2:	80 fb 19             	cmp    $0x19,%bl
f01044c5:	77 08                	ja     f01044cf <strtol+0x9d>
			dig = *s - 'a' + 10;
f01044c7:	0f be d2             	movsbl %dl,%edx
f01044ca:	83 ea 57             	sub    $0x57,%edx
f01044cd:	eb 10                	jmp    f01044df <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01044cf:	8d 72 bf             	lea    -0x41(%edx),%esi
f01044d2:	89 f3                	mov    %esi,%ebx
f01044d4:	80 fb 19             	cmp    $0x19,%bl
f01044d7:	77 16                	ja     f01044ef <strtol+0xbd>
			dig = *s - 'A' + 10;
f01044d9:	0f be d2             	movsbl %dl,%edx
f01044dc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01044df:	3b 55 10             	cmp    0x10(%ebp),%edx
f01044e2:	7d 0b                	jge    f01044ef <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01044e4:	83 c1 01             	add    $0x1,%ecx
f01044e7:	0f af 45 10          	imul   0x10(%ebp),%eax
f01044eb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01044ed:	eb b9                	jmp    f01044a8 <strtol+0x76>

	if (endptr)
f01044ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01044f3:	74 0d                	je     f0104502 <strtol+0xd0>
		*endptr = (char *) s;
f01044f5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044f8:	89 0e                	mov    %ecx,(%esi)
f01044fa:	eb 06                	jmp    f0104502 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01044fc:	85 db                	test   %ebx,%ebx
f01044fe:	74 98                	je     f0104498 <strtol+0x66>
f0104500:	eb 9e                	jmp    f01044a0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0104502:	89 c2                	mov    %eax,%edx
f0104504:	f7 da                	neg    %edx
f0104506:	85 ff                	test   %edi,%edi
f0104508:	0f 45 c2             	cmovne %edx,%eax
}
f010450b:	5b                   	pop    %ebx
f010450c:	5e                   	pop    %esi
f010450d:	5f                   	pop    %edi
f010450e:	5d                   	pop    %ebp
f010450f:	c3                   	ret    

f0104510 <__udivdi3>:
f0104510:	55                   	push   %ebp
f0104511:	57                   	push   %edi
f0104512:	56                   	push   %esi
f0104513:	53                   	push   %ebx
f0104514:	83 ec 1c             	sub    $0x1c,%esp
f0104517:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010451b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010451f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104523:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104527:	85 f6                	test   %esi,%esi
f0104529:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010452d:	89 ca                	mov    %ecx,%edx
f010452f:	89 f8                	mov    %edi,%eax
f0104531:	75 3d                	jne    f0104570 <__udivdi3+0x60>
f0104533:	39 cf                	cmp    %ecx,%edi
f0104535:	0f 87 c5 00 00 00    	ja     f0104600 <__udivdi3+0xf0>
f010453b:	85 ff                	test   %edi,%edi
f010453d:	89 fd                	mov    %edi,%ebp
f010453f:	75 0b                	jne    f010454c <__udivdi3+0x3c>
f0104541:	b8 01 00 00 00       	mov    $0x1,%eax
f0104546:	31 d2                	xor    %edx,%edx
f0104548:	f7 f7                	div    %edi
f010454a:	89 c5                	mov    %eax,%ebp
f010454c:	89 c8                	mov    %ecx,%eax
f010454e:	31 d2                	xor    %edx,%edx
f0104550:	f7 f5                	div    %ebp
f0104552:	89 c1                	mov    %eax,%ecx
f0104554:	89 d8                	mov    %ebx,%eax
f0104556:	89 cf                	mov    %ecx,%edi
f0104558:	f7 f5                	div    %ebp
f010455a:	89 c3                	mov    %eax,%ebx
f010455c:	89 d8                	mov    %ebx,%eax
f010455e:	89 fa                	mov    %edi,%edx
f0104560:	83 c4 1c             	add    $0x1c,%esp
f0104563:	5b                   	pop    %ebx
f0104564:	5e                   	pop    %esi
f0104565:	5f                   	pop    %edi
f0104566:	5d                   	pop    %ebp
f0104567:	c3                   	ret    
f0104568:	90                   	nop
f0104569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104570:	39 ce                	cmp    %ecx,%esi
f0104572:	77 74                	ja     f01045e8 <__udivdi3+0xd8>
f0104574:	0f bd fe             	bsr    %esi,%edi
f0104577:	83 f7 1f             	xor    $0x1f,%edi
f010457a:	0f 84 98 00 00 00    	je     f0104618 <__udivdi3+0x108>
f0104580:	bb 20 00 00 00       	mov    $0x20,%ebx
f0104585:	89 f9                	mov    %edi,%ecx
f0104587:	89 c5                	mov    %eax,%ebp
f0104589:	29 fb                	sub    %edi,%ebx
f010458b:	d3 e6                	shl    %cl,%esi
f010458d:	89 d9                	mov    %ebx,%ecx
f010458f:	d3 ed                	shr    %cl,%ebp
f0104591:	89 f9                	mov    %edi,%ecx
f0104593:	d3 e0                	shl    %cl,%eax
f0104595:	09 ee                	or     %ebp,%esi
f0104597:	89 d9                	mov    %ebx,%ecx
f0104599:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010459d:	89 d5                	mov    %edx,%ebp
f010459f:	8b 44 24 08          	mov    0x8(%esp),%eax
f01045a3:	d3 ed                	shr    %cl,%ebp
f01045a5:	89 f9                	mov    %edi,%ecx
f01045a7:	d3 e2                	shl    %cl,%edx
f01045a9:	89 d9                	mov    %ebx,%ecx
f01045ab:	d3 e8                	shr    %cl,%eax
f01045ad:	09 c2                	or     %eax,%edx
f01045af:	89 d0                	mov    %edx,%eax
f01045b1:	89 ea                	mov    %ebp,%edx
f01045b3:	f7 f6                	div    %esi
f01045b5:	89 d5                	mov    %edx,%ebp
f01045b7:	89 c3                	mov    %eax,%ebx
f01045b9:	f7 64 24 0c          	mull   0xc(%esp)
f01045bd:	39 d5                	cmp    %edx,%ebp
f01045bf:	72 10                	jb     f01045d1 <__udivdi3+0xc1>
f01045c1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01045c5:	89 f9                	mov    %edi,%ecx
f01045c7:	d3 e6                	shl    %cl,%esi
f01045c9:	39 c6                	cmp    %eax,%esi
f01045cb:	73 07                	jae    f01045d4 <__udivdi3+0xc4>
f01045cd:	39 d5                	cmp    %edx,%ebp
f01045cf:	75 03                	jne    f01045d4 <__udivdi3+0xc4>
f01045d1:	83 eb 01             	sub    $0x1,%ebx
f01045d4:	31 ff                	xor    %edi,%edi
f01045d6:	89 d8                	mov    %ebx,%eax
f01045d8:	89 fa                	mov    %edi,%edx
f01045da:	83 c4 1c             	add    $0x1c,%esp
f01045dd:	5b                   	pop    %ebx
f01045de:	5e                   	pop    %esi
f01045df:	5f                   	pop    %edi
f01045e0:	5d                   	pop    %ebp
f01045e1:	c3                   	ret    
f01045e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01045e8:	31 ff                	xor    %edi,%edi
f01045ea:	31 db                	xor    %ebx,%ebx
f01045ec:	89 d8                	mov    %ebx,%eax
f01045ee:	89 fa                	mov    %edi,%edx
f01045f0:	83 c4 1c             	add    $0x1c,%esp
f01045f3:	5b                   	pop    %ebx
f01045f4:	5e                   	pop    %esi
f01045f5:	5f                   	pop    %edi
f01045f6:	5d                   	pop    %ebp
f01045f7:	c3                   	ret    
f01045f8:	90                   	nop
f01045f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104600:	89 d8                	mov    %ebx,%eax
f0104602:	f7 f7                	div    %edi
f0104604:	31 ff                	xor    %edi,%edi
f0104606:	89 c3                	mov    %eax,%ebx
f0104608:	89 d8                	mov    %ebx,%eax
f010460a:	89 fa                	mov    %edi,%edx
f010460c:	83 c4 1c             	add    $0x1c,%esp
f010460f:	5b                   	pop    %ebx
f0104610:	5e                   	pop    %esi
f0104611:	5f                   	pop    %edi
f0104612:	5d                   	pop    %ebp
f0104613:	c3                   	ret    
f0104614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104618:	39 ce                	cmp    %ecx,%esi
f010461a:	72 0c                	jb     f0104628 <__udivdi3+0x118>
f010461c:	31 db                	xor    %ebx,%ebx
f010461e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104622:	0f 87 34 ff ff ff    	ja     f010455c <__udivdi3+0x4c>
f0104628:	bb 01 00 00 00       	mov    $0x1,%ebx
f010462d:	e9 2a ff ff ff       	jmp    f010455c <__udivdi3+0x4c>
f0104632:	66 90                	xchg   %ax,%ax
f0104634:	66 90                	xchg   %ax,%ax
f0104636:	66 90                	xchg   %ax,%ax
f0104638:	66 90                	xchg   %ax,%ax
f010463a:	66 90                	xchg   %ax,%ax
f010463c:	66 90                	xchg   %ax,%ax
f010463e:	66 90                	xchg   %ax,%ax

f0104640 <__umoddi3>:
f0104640:	55                   	push   %ebp
f0104641:	57                   	push   %edi
f0104642:	56                   	push   %esi
f0104643:	53                   	push   %ebx
f0104644:	83 ec 1c             	sub    $0x1c,%esp
f0104647:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010464b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010464f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104653:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104657:	85 d2                	test   %edx,%edx
f0104659:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010465d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104661:	89 f3                	mov    %esi,%ebx
f0104663:	89 3c 24             	mov    %edi,(%esp)
f0104666:	89 74 24 04          	mov    %esi,0x4(%esp)
f010466a:	75 1c                	jne    f0104688 <__umoddi3+0x48>
f010466c:	39 f7                	cmp    %esi,%edi
f010466e:	76 50                	jbe    f01046c0 <__umoddi3+0x80>
f0104670:	89 c8                	mov    %ecx,%eax
f0104672:	89 f2                	mov    %esi,%edx
f0104674:	f7 f7                	div    %edi
f0104676:	89 d0                	mov    %edx,%eax
f0104678:	31 d2                	xor    %edx,%edx
f010467a:	83 c4 1c             	add    $0x1c,%esp
f010467d:	5b                   	pop    %ebx
f010467e:	5e                   	pop    %esi
f010467f:	5f                   	pop    %edi
f0104680:	5d                   	pop    %ebp
f0104681:	c3                   	ret    
f0104682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104688:	39 f2                	cmp    %esi,%edx
f010468a:	89 d0                	mov    %edx,%eax
f010468c:	77 52                	ja     f01046e0 <__umoddi3+0xa0>
f010468e:	0f bd ea             	bsr    %edx,%ebp
f0104691:	83 f5 1f             	xor    $0x1f,%ebp
f0104694:	75 5a                	jne    f01046f0 <__umoddi3+0xb0>
f0104696:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010469a:	0f 82 e0 00 00 00    	jb     f0104780 <__umoddi3+0x140>
f01046a0:	39 0c 24             	cmp    %ecx,(%esp)
f01046a3:	0f 86 d7 00 00 00    	jbe    f0104780 <__umoddi3+0x140>
f01046a9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01046ad:	8b 54 24 04          	mov    0x4(%esp),%edx
f01046b1:	83 c4 1c             	add    $0x1c,%esp
f01046b4:	5b                   	pop    %ebx
f01046b5:	5e                   	pop    %esi
f01046b6:	5f                   	pop    %edi
f01046b7:	5d                   	pop    %ebp
f01046b8:	c3                   	ret    
f01046b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01046c0:	85 ff                	test   %edi,%edi
f01046c2:	89 fd                	mov    %edi,%ebp
f01046c4:	75 0b                	jne    f01046d1 <__umoddi3+0x91>
f01046c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01046cb:	31 d2                	xor    %edx,%edx
f01046cd:	f7 f7                	div    %edi
f01046cf:	89 c5                	mov    %eax,%ebp
f01046d1:	89 f0                	mov    %esi,%eax
f01046d3:	31 d2                	xor    %edx,%edx
f01046d5:	f7 f5                	div    %ebp
f01046d7:	89 c8                	mov    %ecx,%eax
f01046d9:	f7 f5                	div    %ebp
f01046db:	89 d0                	mov    %edx,%eax
f01046dd:	eb 99                	jmp    f0104678 <__umoddi3+0x38>
f01046df:	90                   	nop
f01046e0:	89 c8                	mov    %ecx,%eax
f01046e2:	89 f2                	mov    %esi,%edx
f01046e4:	83 c4 1c             	add    $0x1c,%esp
f01046e7:	5b                   	pop    %ebx
f01046e8:	5e                   	pop    %esi
f01046e9:	5f                   	pop    %edi
f01046ea:	5d                   	pop    %ebp
f01046eb:	c3                   	ret    
f01046ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01046f0:	8b 34 24             	mov    (%esp),%esi
f01046f3:	bf 20 00 00 00       	mov    $0x20,%edi
f01046f8:	89 e9                	mov    %ebp,%ecx
f01046fa:	29 ef                	sub    %ebp,%edi
f01046fc:	d3 e0                	shl    %cl,%eax
f01046fe:	89 f9                	mov    %edi,%ecx
f0104700:	89 f2                	mov    %esi,%edx
f0104702:	d3 ea                	shr    %cl,%edx
f0104704:	89 e9                	mov    %ebp,%ecx
f0104706:	09 c2                	or     %eax,%edx
f0104708:	89 d8                	mov    %ebx,%eax
f010470a:	89 14 24             	mov    %edx,(%esp)
f010470d:	89 f2                	mov    %esi,%edx
f010470f:	d3 e2                	shl    %cl,%edx
f0104711:	89 f9                	mov    %edi,%ecx
f0104713:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104717:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010471b:	d3 e8                	shr    %cl,%eax
f010471d:	89 e9                	mov    %ebp,%ecx
f010471f:	89 c6                	mov    %eax,%esi
f0104721:	d3 e3                	shl    %cl,%ebx
f0104723:	89 f9                	mov    %edi,%ecx
f0104725:	89 d0                	mov    %edx,%eax
f0104727:	d3 e8                	shr    %cl,%eax
f0104729:	89 e9                	mov    %ebp,%ecx
f010472b:	09 d8                	or     %ebx,%eax
f010472d:	89 d3                	mov    %edx,%ebx
f010472f:	89 f2                	mov    %esi,%edx
f0104731:	f7 34 24             	divl   (%esp)
f0104734:	89 d6                	mov    %edx,%esi
f0104736:	d3 e3                	shl    %cl,%ebx
f0104738:	f7 64 24 04          	mull   0x4(%esp)
f010473c:	39 d6                	cmp    %edx,%esi
f010473e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104742:	89 d1                	mov    %edx,%ecx
f0104744:	89 c3                	mov    %eax,%ebx
f0104746:	72 08                	jb     f0104750 <__umoddi3+0x110>
f0104748:	75 11                	jne    f010475b <__umoddi3+0x11b>
f010474a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010474e:	73 0b                	jae    f010475b <__umoddi3+0x11b>
f0104750:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104754:	1b 14 24             	sbb    (%esp),%edx
f0104757:	89 d1                	mov    %edx,%ecx
f0104759:	89 c3                	mov    %eax,%ebx
f010475b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010475f:	29 da                	sub    %ebx,%edx
f0104761:	19 ce                	sbb    %ecx,%esi
f0104763:	89 f9                	mov    %edi,%ecx
f0104765:	89 f0                	mov    %esi,%eax
f0104767:	d3 e0                	shl    %cl,%eax
f0104769:	89 e9                	mov    %ebp,%ecx
f010476b:	d3 ea                	shr    %cl,%edx
f010476d:	89 e9                	mov    %ebp,%ecx
f010476f:	d3 ee                	shr    %cl,%esi
f0104771:	09 d0                	or     %edx,%eax
f0104773:	89 f2                	mov    %esi,%edx
f0104775:	83 c4 1c             	add    $0x1c,%esp
f0104778:	5b                   	pop    %ebx
f0104779:	5e                   	pop    %esi
f010477a:	5f                   	pop    %edi
f010477b:	5d                   	pop    %ebp
f010477c:	c3                   	ret    
f010477d:	8d 76 00             	lea    0x0(%esi),%esi
f0104780:	29 f9                	sub    %edi,%ecx
f0104782:	19 d6                	sbb    %edx,%esi
f0104784:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104788:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010478c:	e9 18 ff ff ff       	jmp    f01046a9 <__umoddi3+0x69>
