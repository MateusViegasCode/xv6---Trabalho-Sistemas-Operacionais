
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	26813103          	ld	sp,616(sp) # 8000a268 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	042000ef          	jal	80000058 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000024:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80000028:	577d                	li	a4,-1
    8000002a:	177e                	slli	a4,a4,0x3f
    8000002c:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002e:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000032:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000036:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    8000003a:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003e:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000042:	000f4737          	lui	a4,0xf4
    80000046:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000004a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004c:	14d79073          	csrw	stimecmp,a5
}
    80000050:	60a2                	ld	ra,8(sp)
    80000052:	6402                	ld	s0,0(sp)
    80000054:	0141                	addi	sp,sp,16
    80000056:	8082                	ret

0000000080000058 <start>:
{
    80000058:	1141                	addi	sp,sp,-16
    8000005a:	e406                	sd	ra,8(sp)
    8000005c:	e022                	sd	s0,0(sp)
    8000005e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    80000060:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000064:	7779                	lui	a4,0xffffe
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb247>
    8000006a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000006c:	6705                	lui	a4,0x1
    8000006e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000072:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000078:	00001797          	auipc	a5,0x1
    8000007c:	e0a78793          	addi	a5,a5,-502 # 80000e82 <main>
    80000080:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000084:	4781                	li	a5,0
    80000086:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    8000008a:	67c1                	lui	a5,0x10
    8000008c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    80000092:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000096:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    8000009a:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000a2:	57fd                	li	a5,-1
    800000a4:	83a9                	srli	a5,a5,0xa
    800000a6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000aa:	47bd                	li	a5,15
    800000ac:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b0:	f6dff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000b4:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000b8:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000ba:	823e                	mv	tp,a5
  asm volatile("mret");
    800000bc:	30200073          	mret
}
    800000c0:	60a2                	ld	ra,8(sp)
    800000c2:	6402                	ld	s0,0(sp)
    800000c4:	0141                	addi	sp,sp,16
    800000c6:	8082                	ret

00000000800000c8 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000c8:	7119                	addi	sp,sp,-128
    800000ca:	fc86                	sd	ra,120(sp)
    800000cc:	f8a2                	sd	s0,112(sp)
    800000ce:	f4a6                	sd	s1,104(sp)
    800000d0:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000d2:	06c05b63          	blez	a2,80000148 <consolewrite+0x80>
    800000d6:	f0ca                	sd	s2,96(sp)
    800000d8:	ecce                	sd	s3,88(sp)
    800000da:	e8d2                	sd	s4,80(sp)
    800000dc:	e4d6                	sd	s5,72(sp)
    800000de:	e0da                	sd	s6,64(sp)
    800000e0:	fc5e                	sd	s7,56(sp)
    800000e2:	f862                	sd	s8,48(sp)
    800000e4:	f466                	sd	s9,40(sp)
    800000e6:	f06a                	sd	s10,32(sp)
    800000e8:	8b2a                	mv	s6,a0
    800000ea:	8bae                	mv	s7,a1
    800000ec:	8a32                	mv	s4,a2
  int i = 0;
    800000ee:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000f0:	02000c93          	li	s9,32
    800000f4:	02000d13          	li	s10,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    800000f8:	f8040a93          	addi	s5,s0,-128
    800000fc:	5c7d                	li	s8,-1
    800000fe:	a025                	j	80000126 <consolewrite+0x5e>
    if (nn > n - i)
    80000100:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000104:	86ce                	mv	a3,s3
    80000106:	01748633          	add	a2,s1,s7
    8000010a:	85da                	mv	a1,s6
    8000010c:	8556                	mv	a0,s5
    8000010e:	19e020ef          	jal	800022ac <either_copyin>
    80000112:	03850d63          	beq	a0,s8,8000014c <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000116:	85ce                	mv	a1,s3
    80000118:	8556                	mv	a0,s5
    8000011a:	7b4000ef          	jal	800008ce <uartwrite>
    i += nn;
    8000011e:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    80000122:	0144d963          	bge	s1,s4,80000134 <consolewrite+0x6c>
    if (nn > n - i)
    80000126:	409a07bb          	subw	a5,s4,s1
    8000012a:	893e                	mv	s2,a5
    8000012c:	fcfcdae3          	bge	s9,a5,80000100 <consolewrite+0x38>
    80000130:	896a                	mv	s2,s10
    80000132:	b7f9                	j	80000100 <consolewrite+0x38>
    80000134:	7906                	ld	s2,96(sp)
    80000136:	69e6                	ld	s3,88(sp)
    80000138:	6a46                	ld	s4,80(sp)
    8000013a:	6aa6                	ld	s5,72(sp)
    8000013c:	6b06                	ld	s6,64(sp)
    8000013e:	7be2                	ld	s7,56(sp)
    80000140:	7c42                	ld	s8,48(sp)
    80000142:	7ca2                	ld	s9,40(sp)
    80000144:	7d02                	ld	s10,32(sp)
    80000146:	a821                	j	8000015e <consolewrite+0x96>
  int i = 0;
    80000148:	4481                	li	s1,0
    8000014a:	a811                	j	8000015e <consolewrite+0x96>
    8000014c:	7906                	ld	s2,96(sp)
    8000014e:	69e6                	ld	s3,88(sp)
    80000150:	6a46                	ld	s4,80(sp)
    80000152:	6aa6                	ld	s5,72(sp)
    80000154:	6b06                	ld	s6,64(sp)
    80000156:	7be2                	ld	s7,56(sp)
    80000158:	7c42                	ld	s8,48(sp)
    8000015a:	7ca2                	ld	s9,40(sp)
    8000015c:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000015e:	8526                	mv	a0,s1
    80000160:	70e6                	ld	ra,120(sp)
    80000162:	7446                	ld	s0,112(sp)
    80000164:	74a6                	ld	s1,104(sp)
    80000166:	6109                	addi	sp,sp,128
    80000168:	8082                	ret

000000008000016a <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016a:	711d                	addi	sp,sp,-96
    8000016c:	ec86                	sd	ra,88(sp)
    8000016e:	e8a2                	sd	s0,80(sp)
    80000170:	e4a6                	sd	s1,72(sp)
    80000172:	e0ca                	sd	s2,64(sp)
    80000174:	fc4e                	sd	s3,56(sp)
    80000176:	f852                	sd	s4,48(sp)
    80000178:	f05a                	sd	s6,32(sp)
    8000017a:	ec5e                	sd	s7,24(sp)
    8000017c:	1080                	addi	s0,sp,96
    8000017e:	8b2a                	mv	s6,a0
    80000180:	8a2e                	mv	s4,a1
    80000182:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000184:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000186:	00012517          	auipc	a0,0x12
    8000018a:	12a50513          	addi	a0,a0,298 # 800122b0 <cons>
    8000018e:	277000ef          	jal	80000c04 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    80000192:	00012497          	auipc	s1,0x12
    80000196:	11e48493          	addi	s1,s1,286 # 800122b0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019a:	00012917          	auipc	s2,0x12
    8000019e:	1ae90913          	addi	s2,s2,430 # 80012348 <cons+0x98>
  while (n > 0) {
    800001a2:	0b305b63          	blez	s3,80000258 <consoleread+0xee>
    while (cons.r == cons.w) {
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	0af71063          	bne	a4,a5,8000024e <consoleread+0xe4>
      if (killed(myproc())) {
    800001b2:	750010ef          	jal	80001902 <myproc>
    800001b6:	78f010ef          	jal	80002144 <killed>
    800001ba:	e12d                	bnez	a0,8000021c <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001bc:	85a6                	mv	a1,s1
    800001be:	854a                	mv	a0,s2
    800001c0:	549010ef          	jal	80001f08 <sleep>
    while (cons.r == cons.w) {
    800001c4:	0984a783          	lw	a5,152(s1)
    800001c8:	09c4a703          	lw	a4,156(s1)
    800001cc:	fef703e3          	beq	a4,a5,800001b2 <consoleread+0x48>
    800001d0:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d2:	00012717          	auipc	a4,0x12
    800001d6:	0de70713          	addi	a4,a4,222 # 800122b0 <cons>
    800001da:	0017869b          	addiw	a3,a5,1
    800001de:	08d72c23          	sw	a3,152(a4)
    800001e2:	07f7f693          	andi	a3,a5,127
    800001e6:	9736                	add	a4,a4,a3
    800001e8:	01874703          	lbu	a4,24(a4)
    800001ec:	00070a9b          	sext.w	s5,a4

    if (c == C('D')) { // end-of-file
    800001f0:	4691                	li	a3,4
    800001f2:	04da8663          	beq	s5,a3,8000023e <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001f6:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001fa:	4685                	li	a3,1
    800001fc:	faf40613          	addi	a2,s0,-81
    80000200:	85d2                	mv	a1,s4
    80000202:	855a                	mv	a0,s6
    80000204:	05e020ef          	jal	80002262 <either_copyout>
    80000208:	57fd                	li	a5,-1
    8000020a:	04f50663          	beq	a0,a5,80000256 <consoleread+0xec>
      break;

    dst++;
    8000020e:	0a05                	addi	s4,s4,1
    --n;
    80000210:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    80000212:	47a9                	li	a5,10
    80000214:	04fa8b63          	beq	s5,a5,8000026a <consoleread+0x100>
    80000218:	7aa2                	ld	s5,40(sp)
    8000021a:	b761                	j	800001a2 <consoleread+0x38>
        release(&cons.lock);
    8000021c:	00012517          	auipc	a0,0x12
    80000220:	09450513          	addi	a0,a0,148 # 800122b0 <cons>
    80000224:	271000ef          	jal	80000c94 <release>
        return -1;
    80000228:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000022a:	60e6                	ld	ra,88(sp)
    8000022c:	6446                	ld	s0,80(sp)
    8000022e:	64a6                	ld	s1,72(sp)
    80000230:	6906                	ld	s2,64(sp)
    80000232:	79e2                	ld	s3,56(sp)
    80000234:	7a42                	ld	s4,48(sp)
    80000236:	7b02                	ld	s6,32(sp)
    80000238:	6be2                	ld	s7,24(sp)
    8000023a:	6125                	addi	sp,sp,96
    8000023c:	8082                	ret
      if (n < target) {
    8000023e:	0179fa63          	bgeu	s3,s7,80000252 <consoleread+0xe8>
        cons.r--;
    80000242:	00012717          	auipc	a4,0x12
    80000246:	10f72323          	sw	a5,262(a4) # 80012348 <cons+0x98>
    8000024a:	7aa2                	ld	s5,40(sp)
    8000024c:	a031                	j	80000258 <consoleread+0xee>
    8000024e:	f456                	sd	s5,40(sp)
    80000250:	b749                	j	800001d2 <consoleread+0x68>
    80000252:	7aa2                	ld	s5,40(sp)
    80000254:	a011                	j	80000258 <consoleread+0xee>
    80000256:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000258:	00012517          	auipc	a0,0x12
    8000025c:	05850513          	addi	a0,a0,88 # 800122b0 <cons>
    80000260:	235000ef          	jal	80000c94 <release>
  return target - n;
    80000264:	413b853b          	subw	a0,s7,s3
    80000268:	b7c9                	j	8000022a <consoleread+0xc0>
    8000026a:	7aa2                	ld	s5,40(sp)
    8000026c:	b7f5                	j	80000258 <consoleread+0xee>

000000008000026e <consputc>:
{
    8000026e:	1141                	addi	sp,sp,-16
    80000270:	e406                	sd	ra,8(sp)
    80000272:	e022                	sd	s0,0(sp)
    80000274:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000276:	10000793          	li	a5,256
    8000027a:	00f50863          	beq	a0,a5,8000028a <consputc+0x1c>
    uartputc_sync(c);
    8000027e:	6e4000ef          	jal	80000962 <uartputc_sync>
}
    80000282:	60a2                	ld	ra,8(sp)
    80000284:	6402                	ld	s0,0(sp)
    80000286:	0141                	addi	sp,sp,16
    80000288:	8082                	ret
    uartputc_sync('\b');
    8000028a:	4521                	li	a0,8
    8000028c:	6d6000ef          	jal	80000962 <uartputc_sync>
    uartputc_sync(' ');
    80000290:	02000513          	li	a0,32
    80000294:	6ce000ef          	jal	80000962 <uartputc_sync>
    uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	6c8000ef          	jal	80000962 <uartputc_sync>
    8000029e:	b7d5                	j	80000282 <consputc+0x14>

00000000800002a0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002a0:	1101                	addi	sp,sp,-32
    800002a2:	ec06                	sd	ra,24(sp)
    800002a4:	e822                	sd	s0,16(sp)
    800002a6:	e426                	sd	s1,8(sp)
    800002a8:	1000                	addi	s0,sp,32
    800002aa:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ac:	00012517          	auipc	a0,0x12
    800002b0:	00450513          	addi	a0,a0,4 # 800122b0 <cons>
    800002b4:	151000ef          	jal	80000c04 <acquire>

  switch (c) {
    800002b8:	47d5                	li	a5,21
    800002ba:	08f48d63          	beq	s1,a5,80000354 <consoleintr+0xb4>
    800002be:	0297c563          	blt	a5,s1,800002e8 <consoleintr+0x48>
    800002c2:	47a1                	li	a5,8
    800002c4:	0ef48263          	beq	s1,a5,800003a8 <consoleintr+0x108>
    800002c8:	47c1                	li	a5,16
    800002ca:	10f49363          	bne	s1,a5,800003d0 <consoleintr+0x130>
  case C('P'): // Print process list.
    procdump();
    800002ce:	028020ef          	jal	800022f6 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002d2:	00012517          	auipc	a0,0x12
    800002d6:	fde50513          	addi	a0,a0,-34 # 800122b0 <cons>
    800002da:	1bb000ef          	jal	80000c94 <release>
}
    800002de:	60e2                	ld	ra,24(sp)
    800002e0:	6442                	ld	s0,16(sp)
    800002e2:	64a2                	ld	s1,8(sp)
    800002e4:	6105                	addi	sp,sp,32
    800002e6:	8082                	ret
  switch (c) {
    800002e8:	07f00793          	li	a5,127
    800002ec:	0af48e63          	beq	s1,a5,800003a8 <consoleintr+0x108>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800002f0:	00012717          	auipc	a4,0x12
    800002f4:	fc070713          	addi	a4,a4,-64 # 800122b0 <cons>
    800002f8:	0a072783          	lw	a5,160(a4)
    800002fc:	09872703          	lw	a4,152(a4)
    80000300:	9f99                	subw	a5,a5,a4
    80000302:	07f00713          	li	a4,127
    80000306:	fcf766e3          	bltu	a4,a5,800002d2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    8000030a:	47b5                	li	a5,13
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x136>
      consputc(c);
    80000310:	8526                	mv	a0,s1
    80000312:	f5dff0ef          	jal	8000026e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000316:	00012717          	auipc	a4,0x12
    8000031a:	f9a70713          	addi	a4,a4,-102 # 800122b0 <cons>
    8000031e:	0a072683          	lw	a3,160(a4)
    80000322:	0016879b          	addiw	a5,a3,1
    80000326:	863e                	mv	a2,a5
    80000328:	0af72023          	sw	a5,160(a4)
    8000032c:	07f6f693          	andi	a3,a3,127
    80000330:	9736                	add	a4,a4,a3
    80000332:	00970c23          	sb	s1,24(a4)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000336:	ff648713          	addi	a4,s1,-10
    8000033a:	c371                	beqz	a4,800003fe <consoleintr+0x15e>
    8000033c:	14f1                	addi	s1,s1,-4
    8000033e:	c0e1                	beqz	s1,800003fe <consoleintr+0x15e>
    80000340:	00012717          	auipc	a4,0x12
    80000344:	00872703          	lw	a4,8(a4) # 80012348 <cons+0x98>
    80000348:	9f99                	subw	a5,a5,a4
    8000034a:	08000713          	li	a4,128
    8000034e:	f8e792e3          	bne	a5,a4,800002d2 <consoleintr+0x32>
    80000352:	a075                	j	800003fe <consoleintr+0x15e>
    80000354:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000356:	00012717          	auipc	a4,0x12
    8000035a:	f5a70713          	addi	a4,a4,-166 # 800122b0 <cons>
    8000035e:	0a072783          	lw	a5,160(a4)
    80000362:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000366:	00012497          	auipc	s1,0x12
    8000036a:	f4a48493          	addi	s1,s1,-182 # 800122b0 <cons>
    while (cons.e != cons.w &&
    8000036e:	4929                	li	s2,10
    80000370:	02f70863          	beq	a4,a5,800003a0 <consoleintr+0x100>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000374:	37fd                	addiw	a5,a5,-1
    80000376:	07f7f713          	andi	a4,a5,127
    8000037a:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    8000037c:	01874703          	lbu	a4,24(a4)
    80000380:	03270263          	beq	a4,s2,800003a4 <consoleintr+0x104>
      cons.e--;
    80000384:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000388:	10000513          	li	a0,256
    8000038c:	ee3ff0ef          	jal	8000026e <consputc>
    while (cons.e != cons.w &&
    80000390:	0a04a783          	lw	a5,160(s1)
    80000394:	09c4a703          	lw	a4,156(s1)
    80000398:	fcf71ee3          	bne	a4,a5,80000374 <consoleintr+0xd4>
    8000039c:	6902                	ld	s2,0(sp)
    8000039e:	bf15                	j	800002d2 <consoleintr+0x32>
    800003a0:	6902                	ld	s2,0(sp)
    800003a2:	bf05                	j	800002d2 <consoleintr+0x32>
    800003a4:	6902                	ld	s2,0(sp)
    800003a6:	b735                	j	800002d2 <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003a8:	00012717          	auipc	a4,0x12
    800003ac:	f0870713          	addi	a4,a4,-248 # 800122b0 <cons>
    800003b0:	0a072783          	lw	a5,160(a4)
    800003b4:	09c72703          	lw	a4,156(a4)
    800003b8:	f0f70de3          	beq	a4,a5,800002d2 <consoleintr+0x32>
      cons.e--;
    800003bc:	37fd                	addiw	a5,a5,-1
    800003be:	00012717          	auipc	a4,0x12
    800003c2:	f8f72923          	sw	a5,-110(a4) # 80012350 <cons+0xa0>
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	ea5ff0ef          	jal	8000026e <consputc>
    800003ce:	b711                	j	800002d2 <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003d0:	f00481e3          	beqz	s1,800002d2 <consoleintr+0x32>
    800003d4:	bf31                	j	800002f0 <consoleintr+0x50>
      consputc(c);
    800003d6:	4529                	li	a0,10
    800003d8:	e97ff0ef          	jal	8000026e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003dc:	00012797          	auipc	a5,0x12
    800003e0:	ed478793          	addi	a5,a5,-300 # 800122b0 <cons>
    800003e4:	0a07a703          	lw	a4,160(a5)
    800003e8:	0017069b          	addiw	a3,a4,1
    800003ec:	8636                	mv	a2,a3
    800003ee:	0ad7a023          	sw	a3,160(a5)
    800003f2:	07f77713          	andi	a4,a4,127
    800003f6:	97ba                	add	a5,a5,a4
    800003f8:	4729                	li	a4,10
    800003fa:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003fe:	00012797          	auipc	a5,0x12
    80000402:	f4c7a723          	sw	a2,-178(a5) # 8001234c <cons+0x9c>
        wakeup(&cons.r);
    80000406:	00012517          	auipc	a0,0x12
    8000040a:	f4250513          	addi	a0,a0,-190 # 80012348 <cons+0x98>
    8000040e:	347010ef          	jal	80001f54 <wakeup>
    80000412:	b5c1                	j	800002d2 <consoleintr+0x32>

0000000080000414 <consoleinit>:

void
consoleinit(void)
{
    80000414:	1141                	addi	sp,sp,-16
    80000416:	e406                	sd	ra,8(sp)
    80000418:	e022                	sd	s0,0(sp)
    8000041a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000041c:	00007597          	auipc	a1,0x7
    80000420:	be458593          	addi	a1,a1,-1052 # 80007000 <etext>
    80000424:	00012517          	auipc	a0,0x12
    80000428:	e8c50513          	addi	a0,a0,-372 # 800122b0 <cons>
    8000042c:	74e000ef          	jal	80000b7a <initlock>

  uartinit();
    80000430:	448000ef          	jal	80000878 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000434:	00022797          	auipc	a5,0x22
    80000438:	fec78793          	addi	a5,a5,-20 # 80022420 <devsw>
    8000043c:	00000717          	auipc	a4,0x0
    80000440:	d2e70713          	addi	a4,a4,-722 # 8000016a <consoleread>
    80000444:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000446:	00000717          	auipc	a4,0x0
    8000044a:	c8270713          	addi	a4,a4,-894 # 800000c8 <consolewrite>
    8000044e:	ef98                	sd	a4,24(a5)
}
    80000450:	60a2                	ld	ra,8(sp)
    80000452:	6402                	ld	s0,0(sp)
    80000454:	0141                	addi	sp,sp,16
    80000456:	8082                	ret

0000000080000458 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000458:	7139                	addi	sp,sp,-64
    8000045a:	fc06                	sd	ra,56(sp)
    8000045c:	f822                	sd	s0,48(sp)
    8000045e:	f04a                	sd	s2,32(sp)
    80000460:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000462:	c219                	beqz	a2,80000468 <printint+0x10>
    80000464:	08054163          	bltz	a0,800004e6 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000468:	4301                	li	t1,0

  i = 0;
    8000046a:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000046e:	86ca                	mv	a3,s2
  i = 0;
    80000470:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80000472:	00007817          	auipc	a6,0x7
    80000476:	29e80813          	addi	a6,a6,670 # 80007710 <digits>
    8000047a:	88ba                	mv	a7,a4
    8000047c:	0017061b          	addiw	a2,a4,1
    80000480:	8732                	mv	a4,a2
    80000482:	02b577b3          	remu	a5,a0,a1
    80000486:	97c2                	add	a5,a5,a6
    80000488:	0007c783          	lbu	a5,0(a5)
    8000048c:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    80000490:	87aa                	mv	a5,a0
    80000492:	02b55533          	divu	a0,a0,a1
    80000496:	0685                	addi	a3,a3,1
    80000498:	feb7f1e3          	bgeu	a5,a1,8000047a <printint+0x22>

  if (sign)
    8000049c:	00030c63          	beqz	t1,800004b4 <printint+0x5c>
    buf[i++] = '-';
    800004a0:	fe060793          	addi	a5,a2,-32
    800004a4:	00878633          	add	a2,a5,s0
    800004a8:	02d00793          	li	a5,45
    800004ac:	fef60423          	sb	a5,-24(a2)
    800004b0:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
    800004b4:	02e05463          	blez	a4,800004dc <printint+0x84>
    800004b8:	f426                	sd	s1,40(sp)
    800004ba:	377d                	addiw	a4,a4,-1
    800004bc:	00e904b3          	add	s1,s2,a4
    800004c0:	197d                	addi	s2,s2,-1
    800004c2:	993a                	add	s2,s2,a4
    800004c4:	1702                	slli	a4,a4,0x20
    800004c6:	9301                	srli	a4,a4,0x20
    800004c8:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004cc:	0004c503          	lbu	a0,0(s1)
    800004d0:	d9fff0ef          	jal	8000026e <consputc>
  while (--i >= 0)
    800004d4:	14fd                	addi	s1,s1,-1
    800004d6:	ff249be3          	bne	s1,s2,800004cc <printint+0x74>
    800004da:	74a2                	ld	s1,40(sp)
}
    800004dc:	70e2                	ld	ra,56(sp)
    800004de:	7442                	ld	s0,48(sp)
    800004e0:	7902                	ld	s2,32(sp)
    800004e2:	6121                	addi	sp,sp,64
    800004e4:	8082                	ret
    x = -xx;
    800004e6:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    800004ea:	4305                	li	t1,1
    x = -xx;
    800004ec:	bfbd                	j	8000046a <printint+0x12>

00000000800004ee <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    800004ee:	7131                	addi	sp,sp,-192
    800004f0:	fc86                	sd	ra,120(sp)
    800004f2:	f8a2                	sd	s0,112(sp)
    800004f4:	f0ca                	sd	s2,96(sp)
    800004f6:	0100                	addi	s0,sp,128
    800004f8:	892a                	mv	s2,a0
    800004fa:	e40c                	sd	a1,8(s0)
    800004fc:	e810                	sd	a2,16(s0)
    800004fe:	ec14                	sd	a3,24(s0)
    80000500:	f018                	sd	a4,32(s0)
    80000502:	f41c                	sd	a5,40(s0)
    80000504:	03043823          	sd	a6,48(s0)
    80000508:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    8000050c:	0000a797          	auipc	a5,0xa
    80000510:	d787a783          	lw	a5,-648(a5) # 8000a284 <panicking>
    80000514:	cf9d                	beqz	a5,80000552 <printk+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000516:	00840793          	addi	a5,s0,8
    8000051a:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000051e:	00094503          	lbu	a0,0(s2)
    80000522:	22050663          	beqz	a0,8000074e <printk+0x260>
    80000526:	f4a6                	sd	s1,104(sp)
    80000528:	ecce                	sd	s3,88(sp)
    8000052a:	e8d2                	sd	s4,80(sp)
    8000052c:	e4d6                	sd	s5,72(sp)
    8000052e:	e0da                	sd	s6,64(sp)
    80000530:	fc5e                	sd	s7,56(sp)
    80000532:	f862                	sd	s8,48(sp)
    80000534:	f06a                	sd	s10,32(sp)
    80000536:	ec6e                	sd	s11,24(sp)
    80000538:	4a01                	li	s4,0
    if (cx != '%') {
    8000053a:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    8000053e:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000542:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    80000546:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    8000054a:	4b29                	li	s6,10
    if (c0 == 'd') {
    8000054c:	06400b93          	li	s7,100
    80000550:	a015                	j	80000574 <printk+0x86>
    acquire(&pr.lock);
    80000552:	00012517          	auipc	a0,0x12
    80000556:	e0650513          	addi	a0,a0,-506 # 80012358 <pr>
    8000055a:	6aa000ef          	jal	80000c04 <acquire>
    8000055e:	bf65                	j	80000516 <printk+0x28>
      consputc(cx);
    80000560:	d0fff0ef          	jal	8000026e <consputc>
      continue;
    80000564:	84d2                	mv	s1,s4
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000566:	2485                	addiw	s1,s1,1
    80000568:	8a26                	mv	s4,s1
    8000056a:	94ca                	add	s1,s1,s2
    8000056c:	0004c503          	lbu	a0,0(s1)
    80000570:	1c050663          	beqz	a0,8000073c <printk+0x24e>
    if (cx != '%') {
    80000574:	ff3516e3          	bne	a0,s3,80000560 <printk+0x72>
    i++;
    80000578:	001a079b          	addiw	a5,s4,1
    8000057c:	84be                	mv	s1,a5
    c0 = fmt[i + 0] & 0xff;
    8000057e:	00f90733          	add	a4,s2,a5
    80000582:	00074a83          	lbu	s5,0(a4)
    if (c0)
    80000586:	200a8963          	beqz	s5,80000798 <printk+0x2aa>
      c1 = fmt[i + 1] & 0xff;
    8000058a:	00174683          	lbu	a3,1(a4)
    if (c1)
    8000058e:	1e068c63          	beqz	a3,80000786 <printk+0x298>
    if (c0 == 'd') {
    80000592:	037a8863          	beq	s5,s7,800005c2 <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    80000596:	f94a8713          	addi	a4,s5,-108
    8000059a:	00173713          	seqz	a4,a4
    8000059e:	f9c68613          	addi	a2,a3,-100
    800005a2:	ee05                	bnez	a2,800005da <printk+0xec>
    800005a4:	cb1d                	beqz	a4,800005da <printk+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005a6:	f8843783          	ld	a5,-120(s0)
    800005aa:	00878713          	addi	a4,a5,8
    800005ae:	f8e43423          	sd	a4,-120(s0)
    800005b2:	4605                	li	a2,1
    800005b4:	85da                	mv	a1,s6
    800005b6:	6388                	ld	a0,0(a5)
    800005b8:	ea1ff0ef          	jal	80000458 <printint>
      i += 1;
    800005bc:	002a049b          	addiw	s1,s4,2
    800005c0:	b75d                	j	80000566 <printk+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005c2:	f8843783          	ld	a5,-120(s0)
    800005c6:	00878713          	addi	a4,a5,8
    800005ca:	f8e43423          	sd	a4,-120(s0)
    800005ce:	4605                	li	a2,1
    800005d0:	85da                	mv	a1,s6
    800005d2:	4388                	lw	a0,0(a5)
    800005d4:	e85ff0ef          	jal	80000458 <printint>
    800005d8:	b779                	j	80000566 <printk+0x78>
      c2 = fmt[i + 2] & 0xff;
    800005da:	97ca                	add	a5,a5,s2
    800005dc:	8636                	mv	a2,a3
    800005de:	0027c683          	lbu	a3,2(a5)
    800005e2:	a2c9                	j	800007a4 <printk+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005e4:	f8843783          	ld	a5,-120(s0)
    800005e8:	00878713          	addi	a4,a5,8
    800005ec:	f8e43423          	sd	a4,-120(s0)
    800005f0:	4605                	li	a2,1
    800005f2:	45a9                	li	a1,10
    800005f4:	6388                	ld	a0,0(a5)
    800005f6:	e63ff0ef          	jal	80000458 <printint>
      i += 2;
    800005fa:	003a049b          	addiw	s1,s4,3
    800005fe:	b7a5                	j	80000566 <printk+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    80000600:	f8843783          	ld	a5,-120(s0)
    80000604:	00878713          	addi	a4,a5,8
    80000608:	f8e43423          	sd	a4,-120(s0)
    8000060c:	4601                	li	a2,0
    8000060e:	85da                	mv	a1,s6
    80000610:	0007e503          	lwu	a0,0(a5)
    80000614:	e45ff0ef          	jal	80000458 <printint>
    80000618:	b7b9                	j	80000566 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    8000061a:	f8843783          	ld	a5,-120(s0)
    8000061e:	00878713          	addi	a4,a5,8
    80000622:	f8e43423          	sd	a4,-120(s0)
    80000626:	4601                	li	a2,0
    80000628:	85da                	mv	a1,s6
    8000062a:	6388                	ld	a0,0(a5)
    8000062c:	e2dff0ef          	jal	80000458 <printint>
      i += 1;
    80000630:	002a049b          	addiw	s1,s4,2
    80000634:	bf0d                	j	80000566 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000636:	f8843783          	ld	a5,-120(s0)
    8000063a:	00878713          	addi	a4,a5,8
    8000063e:	f8e43423          	sd	a4,-120(s0)
    80000642:	4601                	li	a2,0
    80000644:	45a9                	li	a1,10
    80000646:	6388                	ld	a0,0(a5)
    80000648:	e11ff0ef          	jal	80000458 <printint>
      i += 2;
    8000064c:	003a049b          	addiw	s1,s4,3
    80000650:	bf19                	j	80000566 <printk+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4601                	li	a2,0
    80000660:	45c1                	li	a1,16
    80000662:	0007e503          	lwu	a0,0(a5)
    80000666:	df3ff0ef          	jal	80000458 <printint>
    8000066a:	bdf5                	j	80000566 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    8000066c:	f8843783          	ld	a5,-120(s0)
    80000670:	00878713          	addi	a4,a5,8
    80000674:	f8e43423          	sd	a4,-120(s0)
    80000678:	45c1                	li	a1,16
    8000067a:	6388                	ld	a0,0(a5)
    8000067c:	dddff0ef          	jal	80000458 <printint>
      i += 1;
    80000680:	002a049b          	addiw	s1,s4,2
    80000684:	b5cd                	j	80000566 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4601                	li	a2,0
    80000694:	45c1                	li	a1,16
    80000696:	6388                	ld	a0,0(a5)
    80000698:	dc1ff0ef          	jal	80000458 <printint>
      i += 2;
    8000069c:	003a049b          	addiw	s1,s4,3
    800006a0:	b5d9                	j	80000566 <printk+0x78>
    800006a2:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006a4:	f8843783          	ld	a5,-120(s0)
    800006a8:	00878713          	addi	a4,a5,8
    800006ac:	f8e43423          	sd	a4,-120(s0)
    800006b0:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006b4:	03000513          	li	a0,48
    800006b8:	bb7ff0ef          	jal	8000026e <consputc>
  consputc('x');
    800006bc:	07800513          	li	a0,120
    800006c0:	bafff0ef          	jal	8000026e <consputc>
    800006c4:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c6:	00007c97          	auipc	s9,0x7
    800006ca:	04ac8c93          	addi	s9,s9,74 # 80007710 <digits>
    800006ce:	03cad793          	srli	a5,s5,0x3c
    800006d2:	97e6                	add	a5,a5,s9
    800006d4:	0007c503          	lbu	a0,0(a5)
    800006d8:	b97ff0ef          	jal	8000026e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006dc:	0a92                	slli	s5,s5,0x4
    800006de:	3a7d                	addiw	s4,s4,-1
    800006e0:	fe0a17e3          	bnez	s4,800006ce <printk+0x1e0>
    800006e4:	7ca2                	ld	s9,40(sp)
    800006e6:	b541                	j	80000566 <printk+0x78>
    } else if (c0 == 'c') {
      consputc(va_arg(ap, uint));
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4388                	lw	a0,0(a5)
    800006f6:	b79ff0ef          	jal	8000026e <consputc>
    800006fa:	b5b5                	j	80000566 <printk+0x78>
    } else if (c0 == 's') {
      if ((s = va_arg(ap, char *)) == 0)
    800006fc:	f8843783          	ld	a5,-120(s0)
    80000700:	00878713          	addi	a4,a5,8
    80000704:	f8e43423          	sd	a4,-120(s0)
    80000708:	0007ba03          	ld	s4,0(a5)
    8000070c:	000a0d63          	beqz	s4,80000726 <printk+0x238>
        s = "(null)";
      for (; *s; s++)
    80000710:	000a4503          	lbu	a0,0(s4)
    80000714:	e40509e3          	beqz	a0,80000566 <printk+0x78>
        consputc(*s);
    80000718:	b57ff0ef          	jal	8000026e <consputc>
      for (; *s; s++)
    8000071c:	0a05                	addi	s4,s4,1
    8000071e:	000a4503          	lbu	a0,0(s4)
    80000722:	f97d                	bnez	a0,80000718 <printk+0x22a>
    80000724:	b589                	j	80000566 <printk+0x78>
        s = "(null)";
    80000726:	00007a17          	auipc	s4,0x7
    8000072a:	8e2a0a13          	addi	s4,s4,-1822 # 80007008 <etext+0x8>
      for (; *s; s++)
    8000072e:	02800513          	li	a0,40
    80000732:	b7dd                	j	80000718 <printk+0x22a>
    } else if (c0 == '%') {
      consputc('%');
    80000734:	8556                	mv	a0,s5
    80000736:	b39ff0ef          	jal	8000026e <consputc>
    8000073a:	b535                	j	80000566 <printk+0x78>
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7d02                	ld	s10,32(sp)
    8000074c:	6de2                	ld	s11,24(sp)
      consputc(c0);
    }
  }
  va_end(ap);

  if (panicking == 0)
    8000074e:	0000a797          	auipc	a5,0xa
    80000752:	b367a783          	lw	a5,-1226(a5) # 8000a284 <panicking>
    80000756:	c38d                	beqz	a5,80000778 <printk+0x28a>
    release(&pr.lock);

  return 0;
}
    80000758:	4501                	li	a0,0
    8000075a:	70e6                	ld	ra,120(sp)
    8000075c:	7446                	ld	s0,112(sp)
    8000075e:	7906                	ld	s2,96(sp)
    80000760:	6129                	addi	sp,sp,192
    80000762:	8082                	ret
    80000764:	74a6                	ld	s1,104(sp)
    80000766:	69e6                	ld	s3,88(sp)
    80000768:	6a46                	ld	s4,80(sp)
    8000076a:	6aa6                	ld	s5,72(sp)
    8000076c:	6b06                	ld	s6,64(sp)
    8000076e:	7be2                	ld	s7,56(sp)
    80000770:	7c42                	ld	s8,48(sp)
    80000772:	7d02                	ld	s10,32(sp)
    80000774:	6de2                	ld	s11,24(sp)
    80000776:	bfe1                	j	8000074e <printk+0x260>
    release(&pr.lock);
    80000778:	00012517          	auipc	a0,0x12
    8000077c:	be050513          	addi	a0,a0,-1056 # 80012358 <pr>
    80000780:	514000ef          	jal	80000c94 <release>
  return 0;
    80000784:	bfd1                	j	80000758 <printk+0x26a>
    if (c0 == 'd') {
    80000786:	e37a8ee3          	beq	s5,s7,800005c2 <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    8000078a:	f94a8713          	addi	a4,s5,-108
    8000078e:	00173713          	seqz	a4,a4
    80000792:	8636                	mv	a2,a3
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000794:	4781                	li	a5,0
    80000796:	a00d                	j	800007b8 <printk+0x2ca>
    } else if (c0 == 'l' && c1 == 'd') {
    80000798:	f94a8713          	addi	a4,s5,-108
    8000079c:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007a0:	8656                	mv	a2,s5
    800007a2:	86d6                	mv	a3,s5
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007a4:	f9460793          	addi	a5,a2,-108
    800007a8:	0017b793          	seqz	a5,a5
    800007ac:	8ff9                	and	a5,a5,a4
    800007ae:	f9c68593          	addi	a1,a3,-100
    800007b2:	e199                	bnez	a1,800007b8 <printk+0x2ca>
    800007b4:	e20798e3          	bnez	a5,800005e4 <printk+0xf6>
    } else if (c0 == 'u') {
    800007b8:	e58a84e3          	beq	s5,s8,80000600 <printk+0x112>
    } else if (c0 == 'l' && c1 == 'u') {
    800007bc:	f8b60593          	addi	a1,a2,-117
    800007c0:	e199                	bnez	a1,800007c6 <printk+0x2d8>
    800007c2:	e4071ce3          	bnez	a4,8000061a <printk+0x12c>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    800007c6:	f8b68593          	addi	a1,a3,-117
    800007ca:	e199                	bnez	a1,800007d0 <printk+0x2e2>
    800007cc:	e60795e3          	bnez	a5,80000636 <printk+0x148>
    } else if (c0 == 'x') {
    800007d0:	e9aa81e3          	beq	s5,s10,80000652 <printk+0x164>
    } else if (c0 == 'l' && c1 == 'x') {
    800007d4:	f8860613          	addi	a2,a2,-120
    800007d8:	e219                	bnez	a2,800007de <printk+0x2f0>
    800007da:	e80719e3          	bnez	a4,8000066c <printk+0x17e>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    800007de:	f8868693          	addi	a3,a3,-120
    800007e2:	e299                	bnez	a3,800007e8 <printk+0x2fa>
    800007e4:	ea0791e3          	bnez	a5,80000686 <printk+0x198>
    } else if (c0 == 'p') {
    800007e8:	ebba8de3          	beq	s5,s11,800006a2 <printk+0x1b4>
    } else if (c0 == 'c') {
    800007ec:	06300793          	li	a5,99
    800007f0:	eefa8ce3          	beq	s5,a5,800006e8 <printk+0x1fa>
    } else if (c0 == 's') {
    800007f4:	07300793          	li	a5,115
    800007f8:	f0fa82e3          	beq	s5,a5,800006fc <printk+0x20e>
    } else if (c0 == '%') {
    800007fc:	02500793          	li	a5,37
    80000800:	f2fa8ae3          	beq	s5,a5,80000734 <printk+0x246>
    } else if (c0 == 0) {
    80000804:	f60a80e3          	beqz	s5,80000764 <printk+0x276>
      consputc('%');
    80000808:	02500513          	li	a0,37
    8000080c:	a63ff0ef          	jal	8000026e <consputc>
      consputc(c0);
    80000810:	8556                	mv	a0,s5
    80000812:	a5dff0ef          	jal	8000026e <consputc>
    80000816:	bb81                	j	80000566 <printk+0x78>

0000000080000818 <panic>:

void
panic(char *s)
{
    80000818:	1101                	addi	sp,sp,-32
    8000081a:	ec06                	sd	ra,24(sp)
    8000081c:	e822                	sd	s0,16(sp)
    8000081e:	e426                	sd	s1,8(sp)
    80000820:	e04a                	sd	s2,0(sp)
    80000822:	1000                	addi	s0,sp,32
    80000824:	892a                	mv	s2,a0
  panicking = 1;
    80000826:	4485                	li	s1,1
    80000828:	0000a797          	auipc	a5,0xa
    8000082c:	a497ae23          	sw	s1,-1444(a5) # 8000a284 <panicking>
  printk("panic: ");
    80000830:	00006517          	auipc	a0,0x6
    80000834:	7e850513          	addi	a0,a0,2024 # 80007018 <etext+0x18>
    80000838:	cb7ff0ef          	jal	800004ee <printk>
  printk("%s\n", s);
    8000083c:	85ca                	mv	a1,s2
    8000083e:	00006517          	auipc	a0,0x6
    80000842:	7e250513          	addi	a0,a0,2018 # 80007020 <etext+0x20>
    80000846:	ca9ff0ef          	jal	800004ee <printk>
  panicked = 1; // freeze uart output from other CPUs
    8000084a:	0000a797          	auipc	a5,0xa
    8000084e:	a297ab23          	sw	s1,-1482(a5) # 8000a280 <panicked>
  for (;;)
    80000852:	a001                	j	80000852 <panic+0x3a>

0000000080000854 <printkinit>:
    ;
}

void
printkinit(void)
{
    80000854:	1141                	addi	sp,sp,-16
    80000856:	e406                	sd	ra,8(sp)
    80000858:	e022                	sd	s0,0(sp)
    8000085a:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    8000085c:	00006597          	auipc	a1,0x6
    80000860:	7cc58593          	addi	a1,a1,1996 # 80007028 <etext+0x28>
    80000864:	00012517          	auipc	a0,0x12
    80000868:	af450513          	addi	a0,a0,-1292 # 80012358 <pr>
    8000086c:	30e000ef          	jal	80000b7a <initlock>
}
    80000870:	60a2                	ld	ra,8(sp)
    80000872:	6402                	ld	s0,0(sp)
    80000874:	0141                	addi	sp,sp,16
    80000876:	8082                	ret

0000000080000878 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000878:	1141                	addi	sp,sp,-16
    8000087a:	e406                	sd	ra,8(sp)
    8000087c:	e022                	sd	s0,0(sp)
    8000087e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000880:	100007b7          	lui	a5,0x10000
    80000884:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000888:	10000737          	lui	a4,0x10000
    8000088c:	f8000693          	li	a3,-128
    80000890:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000894:	468d                	li	a3,3
    80000896:	10000637          	lui	a2,0x10000
    8000089a:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000089e:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008a2:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008a6:	8732                	mv	a4,a2
    800008a8:	461d                	li	a2,7
    800008aa:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ae:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008b2:	00006597          	auipc	a1,0x6
    800008b6:	77e58593          	addi	a1,a1,1918 # 80007030 <etext+0x30>
    800008ba:	00012517          	auipc	a0,0x12
    800008be:	ab650513          	addi	a0,a0,-1354 # 80012370 <tx_lock>
    800008c2:	2b8000ef          	jal	80000b7a <initlock>
}
    800008c6:	60a2                	ld	ra,8(sp)
    800008c8:	6402                	ld	s0,0(sp)
    800008ca:	0141                	addi	sp,sp,16
    800008cc:	8082                	ret

00000000800008ce <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008ce:	715d                	addi	sp,sp,-80
    800008d0:	e486                	sd	ra,72(sp)
    800008d2:	e0a2                	sd	s0,64(sp)
    800008d4:	fc26                	sd	s1,56(sp)
    800008d6:	ec56                	sd	s5,24(sp)
    800008d8:	0880                	addi	s0,sp,80
    800008da:	8aaa                	mv	s5,a0
    800008dc:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008de:	00012517          	auipc	a0,0x12
    800008e2:	a9250513          	addi	a0,a0,-1390 # 80012370 <tx_lock>
    800008e6:	31e000ef          	jal	80000c04 <acquire>

  int i = 0;
  while (i < n) {
    800008ea:	06905063          	blez	s1,8000094a <uartwrite+0x7c>
    800008ee:	f84a                	sd	s2,48(sp)
    800008f0:	f44e                	sd	s3,40(sp)
    800008f2:	f052                	sd	s4,32(sp)
    800008f4:	e85a                	sd	s6,16(sp)
    800008f6:	e45e                	sd	s7,8(sp)
    800008f8:	8a56                	mv	s4,s5
    800008fa:	9aa6                	add	s5,s5,s1
    while (tx_busy != 0) {
    800008fc:	0000a497          	auipc	s1,0xa
    80000900:	99048493          	addi	s1,s1,-1648 # 8000a28c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000904:	00012997          	auipc	s3,0x12
    80000908:	a6c98993          	addi	s3,s3,-1428 # 80012370 <tx_lock>
    8000090c:	0000a917          	auipc	s2,0xa
    80000910:	97c90913          	addi	s2,s2,-1668 # 8000a288 <tx_chan>
    }

    WriteReg(THR, buf[i]);
    80000914:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000918:	4b05                	li	s6,1
    8000091a:	a005                	j	8000093a <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    8000091c:	85ce                	mv	a1,s3
    8000091e:	854a                	mv	a0,s2
    80000920:	5e8010ef          	jal	80001f08 <sleep>
    while (tx_busy != 0) {
    80000924:	409c                	lw	a5,0(s1)
    80000926:	fbfd                	bnez	a5,8000091c <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000928:	000a4783          	lbu	a5,0(s4)
    8000092c:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    80000930:	0164a023          	sw	s6,0(s1)
  while (i < n) {
    80000934:	0a05                	addi	s4,s4,1
    80000936:	015a0563          	beq	s4,s5,80000940 <uartwrite+0x72>
    while (tx_busy != 0) {
    8000093a:	409c                	lw	a5,0(s1)
    8000093c:	f3e5                	bnez	a5,8000091c <uartwrite+0x4e>
    8000093e:	b7ed                	j	80000928 <uartwrite+0x5a>
    80000940:	7942                	ld	s2,48(sp)
    80000942:	79a2                	ld	s3,40(sp)
    80000944:	7a02                	ld	s4,32(sp)
    80000946:	6b42                	ld	s6,16(sp)
    80000948:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    8000094a:	00012517          	auipc	a0,0x12
    8000094e:	a2650513          	addi	a0,a0,-1498 # 80012370 <tx_lock>
    80000952:	342000ef          	jal	80000c94 <release>
}
    80000956:	60a6                	ld	ra,72(sp)
    80000958:	6406                	ld	s0,64(sp)
    8000095a:	74e2                	ld	s1,56(sp)
    8000095c:	6ae2                	ld	s5,24(sp)
    8000095e:	6161                	addi	sp,sp,80
    80000960:	8082                	ret

0000000080000962 <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000962:	1101                	addi	sp,sp,-32
    80000964:	ec06                	sd	ra,24(sp)
    80000966:	e822                	sd	s0,16(sp)
    80000968:	e426                	sd	s1,8(sp)
    8000096a:	1000                	addi	s0,sp,32
    8000096c:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000096e:	0000a797          	auipc	a5,0xa
    80000972:	9167a783          	lw	a5,-1770(a5) # 8000a284 <panicking>
    80000976:	cf95                	beqz	a5,800009b2 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000978:	0000a797          	auipc	a5,0xa
    8000097c:	9087a783          	lw	a5,-1784(a5) # 8000a280 <panicked>
    80000980:	ef85                	bnez	a5,800009b8 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000982:	10000737          	lui	a4,0x10000
    80000986:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000988:	00074783          	lbu	a5,0(a4)
    8000098c:	0207f793          	andi	a5,a5,32
    80000990:	dfe5                	beqz	a5,80000988 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    80000992:	0ff4f513          	zext.b	a0,s1
    80000996:	100007b7          	lui	a5,0x10000
    8000099a:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    8000099e:	0000a797          	auipc	a5,0xa
    800009a2:	8e67a783          	lw	a5,-1818(a5) # 8000a284 <panicking>
    800009a6:	cb91                	beqz	a5,800009ba <uartputc_sync+0x58>
    pop_off();
}
    800009a8:	60e2                	ld	ra,24(sp)
    800009aa:	6442                	ld	s0,16(sp)
    800009ac:	64a2                	ld	s1,8(sp)
    800009ae:	6105                	addi	sp,sp,32
    800009b0:	8082                	ret
    push_off();
    800009b2:	20e000ef          	jal	80000bc0 <push_off>
    800009b6:	b7c9                	j	80000978 <uartputc_sync+0x16>
    for (;;)
    800009b8:	a001                	j	800009b8 <uartputc_sync+0x56>
    pop_off();
    800009ba:	28a000ef          	jal	80000c44 <pop_off>
}
    800009be:	b7ed                	j	800009a8 <uartputc_sync+0x46>

00000000800009c0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009c0:	1101                	addi	sp,sp,-32
    800009c2:	ec06                	sd	ra,24(sp)
    800009c4:	e822                	sd	s0,16(sp)
    800009c6:	e426                	sd	s1,8(sp)
    800009c8:	e04a                	sd	s2,0(sp)
    800009ca:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009cc:	100007b7          	lui	a5,0x10000
    800009d0:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    800009d4:	00012517          	auipc	a0,0x12
    800009d8:	99c50513          	addi	a0,a0,-1636 # 80012370 <tx_lock>
    800009dc:	228000ef          	jal	80000c04 <acquire>
  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e8:	0207f793          	andi	a5,a5,32
    800009ec:	e78d                	bnez	a5,80000a16 <uartintr+0x56>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009ee:	00012517          	auipc	a0,0x12
    800009f2:	98250513          	addi	a0,a0,-1662 # 80012370 <tx_lock>
    800009f6:	29e000ef          	jal	80000c94 <release>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009fa:	100004b7          	lui	s1,0x10000
    800009fe:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    80000a00:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    80000a04:	0004c783          	lbu	a5,0(s1)
    80000a08:	8b85                	andi	a5,a5,1
    80000a0a:	c38d                	beqz	a5,80000a2c <uartintr+0x6c>
    return ReadReg(RHR);
    80000a0c:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    80000a10:	891ff0ef          	jal	800002a0 <consoleintr>
  while (1) {
    80000a14:	bfc5                	j	80000a04 <uartintr+0x44>
    tx_busy = 0;
    80000a16:	0000a797          	auipc	a5,0xa
    80000a1a:	8607ab23          	sw	zero,-1930(a5) # 8000a28c <tx_busy>
    wakeup(&tx_chan);
    80000a1e:	0000a517          	auipc	a0,0xa
    80000a22:	86a50513          	addi	a0,a0,-1942 # 8000a288 <tx_chan>
    80000a26:	52e010ef          	jal	80001f54 <wakeup>
    80000a2a:	b7d1                	j	800009ee <uartintr+0x2e>
  }
}
    80000a2c:	60e2                	ld	ra,24(sp)
    80000a2e:	6442                	ld	s0,16(sp)
    80000a30:	64a2                	ld	s1,8(sp)
    80000a32:	6902                	ld	s2,0(sp)
    80000a34:	6105                	addi	sp,sp,32
    80000a36:	8082                	ret

0000000080000a38 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a38:	1101                	addi	sp,sp,-32
    80000a3a:	ec06                	sd	ra,24(sp)
    80000a3c:	e822                	sd	s0,16(sp)
    80000a3e:	e426                	sd	s1,8(sp)
    80000a40:	e04a                	sd	s2,0(sp)
    80000a42:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a44:	00023797          	auipc	a5,0x23
    80000a48:	b7478793          	addi	a5,a5,-1164 # 800235b8 <end>
    80000a4c:	00f53733          	sltu	a4,a0,a5
    80000a50:	47c5                	li	a5,17
    80000a52:	07ee                	slli	a5,a5,0x1b
    80000a54:	17fd                	addi	a5,a5,-1
    80000a56:	00a7b7b3          	sltu	a5,a5,a0
    80000a5a:	8fd9                	or	a5,a5,a4
    80000a5c:	ef95                	bnez	a5,80000a98 <kfree+0x60>
    80000a5e:	84aa                	mv	s1,a0
    80000a60:	03451793          	slli	a5,a0,0x34
    80000a64:	eb95                	bnez	a5,80000a98 <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a66:	6605                	lui	a2,0x1
    80000a68:	4585                	li	a1,1
    80000a6a:	262000ef          	jal	80000ccc <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a6e:	00012917          	auipc	s2,0x12
    80000a72:	91a90913          	addi	s2,s2,-1766 # 80012388 <kmem>
    80000a76:	854a                	mv	a0,s2
    80000a78:	18c000ef          	jal	80000c04 <acquire>
  r->next = kmem.freelist;
    80000a7c:	01893783          	ld	a5,24(s2)
    80000a80:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a82:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a86:	854a                	mv	a0,s2
    80000a88:	20c000ef          	jal	80000c94 <release>
}
    80000a8c:	60e2                	ld	ra,24(sp)
    80000a8e:	6442                	ld	s0,16(sp)
    80000a90:	64a2                	ld	s1,8(sp)
    80000a92:	6902                	ld	s2,0(sp)
    80000a94:	6105                	addi	sp,sp,32
    80000a96:	8082                	ret
    panic("kfree");
    80000a98:	00006517          	auipc	a0,0x6
    80000a9c:	5a050513          	addi	a0,a0,1440 # 80007038 <etext+0x38>
    80000aa0:	d79ff0ef          	jal	80000818 <panic>

0000000080000aa4 <freerange>:
{
    80000aa4:	7179                	addi	sp,sp,-48
    80000aa6:	f406                	sd	ra,40(sp)
    80000aa8:	f022                	sd	s0,32(sp)
    80000aaa:	ec26                	sd	s1,24(sp)
    80000aac:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000aae:	6785                	lui	a5,0x1
    80000ab0:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab4:	00e504b3          	add	s1,a0,a4
    80000ab8:	777d                	lui	a4,0xfffff
    80000aba:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000abc:	94be                	add	s1,s1,a5
    80000abe:	0295e263          	bltu	a1,s1,80000ae2 <freerange+0x3e>
    80000ac2:	e84a                	sd	s2,16(sp)
    80000ac4:	e44e                	sd	s3,8(sp)
    80000ac6:	e052                	sd	s4,0(sp)
    80000ac8:	892e                	mv	s2,a1
    kfree(p);
    80000aca:	8a3a                	mv	s4,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000acc:	89be                	mv	s3,a5
    kfree(p);
    80000ace:	01448533          	add	a0,s1,s4
    80000ad2:	f67ff0ef          	jal	80000a38 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ad6:	94ce                	add	s1,s1,s3
    80000ad8:	fe997be3          	bgeu	s2,s1,80000ace <freerange+0x2a>
    80000adc:	6942                	ld	s2,16(sp)
    80000ade:	69a2                	ld	s3,8(sp)
    80000ae0:	6a02                	ld	s4,0(sp)
}
    80000ae2:	70a2                	ld	ra,40(sp)
    80000ae4:	7402                	ld	s0,32(sp)
    80000ae6:	64e2                	ld	s1,24(sp)
    80000ae8:	6145                	addi	sp,sp,48
    80000aea:	8082                	ret

0000000080000aec <kinit>:
{
    80000aec:	1141                	addi	sp,sp,-16
    80000aee:	e406                	sd	ra,8(sp)
    80000af0:	e022                	sd	s0,0(sp)
    80000af2:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af4:	00006597          	auipc	a1,0x6
    80000af8:	54c58593          	addi	a1,a1,1356 # 80007040 <etext+0x40>
    80000afc:	00012517          	auipc	a0,0x12
    80000b00:	88c50513          	addi	a0,a0,-1908 # 80012388 <kmem>
    80000b04:	076000ef          	jal	80000b7a <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b08:	45c5                	li	a1,17
    80000b0a:	05ee                	slli	a1,a1,0x1b
    80000b0c:	00023517          	auipc	a0,0x23
    80000b10:	aac50513          	addi	a0,a0,-1364 # 800235b8 <end>
    80000b14:	f91ff0ef          	jal	80000aa4 <freerange>
}
    80000b18:	60a2                	ld	ra,8(sp)
    80000b1a:	6402                	ld	s0,0(sp)
    80000b1c:	0141                	addi	sp,sp,16
    80000b1e:	8082                	ret

0000000080000b20 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b20:	1101                	addi	sp,sp,-32
    80000b22:	ec06                	sd	ra,24(sp)
    80000b24:	e822                	sd	s0,16(sp)
    80000b26:	e426                	sd	s1,8(sp)
    80000b28:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2a:	00012517          	auipc	a0,0x12
    80000b2e:	85e50513          	addi	a0,a0,-1954 # 80012388 <kmem>
    80000b32:	0d2000ef          	jal	80000c04 <acquire>
  r = kmem.freelist;
    80000b36:	00012497          	auipc	s1,0x12
    80000b3a:	86a4b483          	ld	s1,-1942(s1) # 800123a0 <kmem+0x18>
  if (r)
    80000b3e:	c49d                	beqz	s1,80000b6c <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012717          	auipc	a4,0x12
    80000b46:	84f73f23          	sd	a5,-1954(a4) # 800123a0 <kmem+0x18>
  release(&kmem.lock);
    80000b4a:	00012517          	auipc	a0,0x12
    80000b4e:	83e50513          	addi	a0,a0,-1986 # 80012388 <kmem>
    80000b52:	142000ef          	jal	80000c94 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000b56:	6605                	lui	a2,0x1
    80000b58:	4595                	li	a1,5
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	170000ef          	jal	80000ccc <memset>
  return (void *)r;
}
    80000b60:	8526                	mv	a0,s1
    80000b62:	60e2                	ld	ra,24(sp)
    80000b64:	6442                	ld	s0,16(sp)
    80000b66:	64a2                	ld	s1,8(sp)
    80000b68:	6105                	addi	sp,sp,32
    80000b6a:	8082                	ret
  release(&kmem.lock);
    80000b6c:	00012517          	auipc	a0,0x12
    80000b70:	81c50513          	addi	a0,a0,-2020 # 80012388 <kmem>
    80000b74:	120000ef          	jal	80000c94 <release>
  if (r)
    80000b78:	b7e5                	j	80000b60 <kalloc+0x40>

0000000080000b7a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b7a:	1141                	addi	sp,sp,-16
    80000b7c:	e406                	sd	ra,8(sp)
    80000b7e:	e022                	sd	s0,0(sp)
    80000b80:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b82:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b84:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b88:	00053823          	sd	zero,16(a0)
}
    80000b8c:	60a2                	ld	ra,8(sp)
    80000b8e:	6402                	ld	s0,0(sp)
    80000b90:	0141                	addi	sp,sp,16
    80000b92:	8082                	ret

0000000080000b94 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b94:	411c                	lw	a5,0(a0)
    80000b96:	e399                	bnez	a5,80000b9c <holding+0x8>
    80000b98:	4501                	li	a0,0
  return r;
}
    80000b9a:	8082                	ret
{
    80000b9c:	1101                	addi	sp,sp,-32
    80000b9e:	ec06                	sd	ra,24(sp)
    80000ba0:	e822                	sd	s0,16(sp)
    80000ba2:	e426                	sd	s1,8(sp)
    80000ba4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba6:	691c                	ld	a5,16(a0)
    80000ba8:	84be                	mv	s1,a5
    80000baa:	539000ef          	jal	800018e2 <mycpu>
    80000bae:	40a48533          	sub	a0,s1,a0
    80000bb2:	00153513          	seqz	a0,a0
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret

0000000080000bc0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000bca:	100027f3          	csrr	a5,sstatus
    80000bce:	84be                	mv	s1,a5
    80000bd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80000bd6:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if (mycpu()->noff == 0)
    80000bda:	509000ef          	jal	800018e2 <mycpu>
    80000bde:	5d3c                	lw	a5,120(a0)
    80000be0:	cb99                	beqz	a5,80000bf6 <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be2:	501000ef          	jal	800018e2 <mycpu>
    80000be6:	5d3c                	lw	a5,120(a0)
    80000be8:	2785                	addiw	a5,a5,1
    80000bea:	dd3c                	sw	a5,120(a0)
}
    80000bec:	60e2                	ld	ra,24(sp)
    80000bee:	6442                	ld	s0,16(sp)
    80000bf0:	64a2                	ld	s1,8(sp)
    80000bf2:	6105                	addi	sp,sp,32
    80000bf4:	8082                	ret
    mycpu()->intena = old;
    80000bf6:	4ed000ef          	jal	800018e2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bfa:	0014d793          	srli	a5,s1,0x1
    80000bfe:	8b85                	andi	a5,a5,1
    80000c00:	dd7c                	sw	a5,124(a0)
    80000c02:	b7c5                	j	80000be2 <push_off+0x22>

0000000080000c04 <acquire>:
{
    80000c04:	1101                	addi	sp,sp,-32
    80000c06:	ec06                	sd	ra,24(sp)
    80000c08:	e822                	sd	s0,16(sp)
    80000c0a:	e426                	sd	s1,8(sp)
    80000c0c:	1000                	addi	s0,sp,32
    80000c0e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c10:	fb1ff0ef          	jal	80000bc0 <push_off>
  if (holding(lk))
    80000c14:	8526                	mv	a0,s1
    80000c16:	f7fff0ef          	jal	80000b94 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c1a:	4705                	li	a4,1
  if (holding(lk))
    80000c1c:	ed11                	bnez	a0,80000c38 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c1e:	87ba                	mv	a5,a4
    80000c20:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c24:	2781                	sext.w	a5,a5
    80000c26:	ffe5                	bnez	a5,80000c1e <acquire+0x1a>
  lk->cpu = mycpu();
    80000c28:	4bb000ef          	jal	800018e2 <mycpu>
    80000c2c:	e888                	sd	a0,16(s1)
}
    80000c2e:	60e2                	ld	ra,24(sp)
    80000c30:	6442                	ld	s0,16(sp)
    80000c32:	64a2                	ld	s1,8(sp)
    80000c34:	6105                	addi	sp,sp,32
    80000c36:	8082                	ret
    panic("acquire");
    80000c38:	00006517          	auipc	a0,0x6
    80000c3c:	41050513          	addi	a0,a0,1040 # 80007048 <etext+0x48>
    80000c40:	bd9ff0ef          	jal	80000818 <panic>

0000000080000c44 <pop_off>:

void
pop_off(void)
{
    80000c44:	1141                	addi	sp,sp,-16
    80000c46:	e406                	sd	ra,8(sp)
    80000c48:	e022                	sd	s0,0(sp)
    80000c4a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c4c:	497000ef          	jal	800018e2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c50:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c54:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c56:	e39d                	bnez	a5,80000c7c <pop_off+0x38>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c58:	5d3c                	lw	a5,120(a0)
    80000c5a:	02f05763          	blez	a5,80000c88 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c5e:	37fd                	addiw	a5,a5,-1
    80000c60:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c62:	eb89                	bnez	a5,80000c74 <pop_off+0x30>
    80000c64:	5d7c                	lw	a5,124(a0)
    80000c66:	c799                	beqz	a5,80000c74 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80000c70:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c74:	60a2                	ld	ra,8(sp)
    80000c76:	6402                	ld	s0,0(sp)
    80000c78:	0141                	addi	sp,sp,16
    80000c7a:	8082                	ret
    panic("pop_off - interruptible");
    80000c7c:	00006517          	auipc	a0,0x6
    80000c80:	3d450513          	addi	a0,a0,980 # 80007050 <etext+0x50>
    80000c84:	b95ff0ef          	jal	80000818 <panic>
    panic("pop_off");
    80000c88:	00006517          	auipc	a0,0x6
    80000c8c:	3e050513          	addi	a0,a0,992 # 80007068 <etext+0x68>
    80000c90:	b89ff0ef          	jal	80000818 <panic>

0000000080000c94 <release>:
{
    80000c94:	1101                	addi	sp,sp,-32
    80000c96:	ec06                	sd	ra,24(sp)
    80000c98:	e822                	sd	s0,16(sp)
    80000c9a:	e426                	sd	s1,8(sp)
    80000c9c:	1000                	addi	s0,sp,32
    80000c9e:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000ca0:	ef5ff0ef          	jal	80000b94 <holding>
    80000ca4:	cd11                	beqz	a0,80000cc0 <release+0x2c>
  lk->cpu = 0;
    80000ca6:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000caa:	0310000f          	fence	rw,w
    80000cae:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cb2:	f93ff0ef          	jal	80000c44 <pop_off>
}
    80000cb6:	60e2                	ld	ra,24(sp)
    80000cb8:	6442                	ld	s0,16(sp)
    80000cba:	64a2                	ld	s1,8(sp)
    80000cbc:	6105                	addi	sp,sp,32
    80000cbe:	8082                	ret
    panic("release");
    80000cc0:	00006517          	auipc	a0,0x6
    80000cc4:	3b050513          	addi	a0,a0,944 # 80007070 <etext+0x70>
    80000cc8:	b51ff0ef          	jal	80000818 <panic>

0000000080000ccc <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000ccc:	1141                	addi	sp,sp,-16
    80000cce:	e406                	sd	ra,8(sp)
    80000cd0:	e022                	sd	s0,0(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1e>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x14>
  }
  return dst;
}
    80000cea:	60a2                	ld	ra,8(sp)
    80000cec:	6402                	ld	s0,0(sp)
    80000cee:	0141                	addi	sp,sp,16
    80000cf0:	8082                	ret

0000000080000cf2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf2:	1141                	addi	sp,sp,-16
    80000cf4:	e406                	sd	ra,8(sp)
    80000cf6:	e022                	sd	s0,0(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000cfa:	c61d                	beqz	a2,80000d28 <memcmp+0x36>
    80000cfc:	1602                	slli	a2,a2,0x20
    80000cfe:	9201                	srli	a2,a2,0x20
    80000d00:	00c506b3          	add	a3,a0,a2
    if (*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x12>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x2e>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	60a2                	ld	ra,8(sp)
    80000d22:	6402                	ld	s0,0(sp)
    80000d24:	0141                	addi	sp,sp,16
    80000d26:	8082                	ret
  return 0;
    80000d28:	4501                	li	a0,0
    80000d2a:	bfdd                	j	80000d20 <memcmp+0x2e>

0000000080000d2c <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000d2c:	1141                	addi	sp,sp,-16
    80000d2e:	e406                	sd	ra,8(sp)
    80000d30:	e022                	sd	s0,0(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x28>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000d36:	02a5e363          	bltu	a1,a0,80000d5c <memmove+0x30>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d50:	feb79ae3          	bne	a5,a1,80000d44 <memmove+0x18>

  return dst;
}
    80000d54:	60a2                	ld	ra,8(sp)
    80000d56:	6402                	ld	s0,0(sp)
    80000d58:	0141                	addi	sp,sp,16
    80000d5a:	8082                	ret
  if (s < d && s + n > d) {
    80000d5c:	02061693          	slli	a3,a2,0x20
    80000d60:	9281                	srli	a3,a3,0x20
    80000d62:	00d58733          	add	a4,a1,a3
    80000d66:	fce57ae3          	bgeu	a0,a4,80000d3a <memmove+0xe>
    d += n;
    80000d6a:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d6c:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d70:	1782                	slli	a5,a5,0x20
    80000d72:	9381                	srli	a5,a5,0x20
    80000d74:	fff7c793          	not	a5,a5
    80000d78:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d7a:	177d                	addi	a4,a4,-1
    80000d7c:	16fd                	addi	a3,a3,-1
    80000d7e:	00074603          	lbu	a2,0(a4)
    80000d82:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d86:	fee79ae3          	bne	a5,a4,80000d7a <memmove+0x4e>
    80000d8a:	b7e9                	j	80000d54 <memmove+0x28>

0000000080000d8c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d8c:	1141                	addi	sp,sp,-16
    80000d8e:	e406                	sd	ra,8(sp)
    80000d90:	e022                	sd	s0,0(sp)
    80000d92:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d94:	f99ff0ef          	jal	80000d2c <memmove>
}
    80000d98:	60a2                	ld	ra,8(sp)
    80000d9a:	6402                	ld	s0,0(sp)
    80000d9c:	0141                	addi	sp,sp,16
    80000d9e:	8082                	ret

0000000080000da0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e406                	sd	ra,8(sp)
    80000da4:	e022                	sd	s0,0(sp)
    80000da6:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x24>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x28>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x28>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0xa>
  if (n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a801                	j	80000dd2 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a031                	j	80000dd2 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000dc8:	00054503          	lbu	a0,0(a0)
    80000dcc:	0005c783          	lbu	a5,0(a1)
    80000dd0:	9d1d                	subw	a0,a0,a5
}
    80000dd2:	60a2                	ld	ra,8(sp)
    80000dd4:	6402                	ld	s0,0(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret

0000000080000dda <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e406                	sd	ra,8(sp)
    80000dde:	e022                	sd	s0,0(sp)
    80000de0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000de2:	87aa                	mv	a5,a0
    80000de4:	a011                	j	80000de8 <strncpy+0xe>
    80000de6:	8636                	mv	a2,a3
    80000de8:	02c05863          	blez	a2,80000e18 <strncpy+0x3e>
    80000dec:	fff6069b          	addiw	a3,a2,-1
    80000df0:	8836                	mv	a6,a3
    80000df2:	0785                	addi	a5,a5,1
    80000df4:	0005c703          	lbu	a4,0(a1)
    80000df8:	fee78fa3          	sb	a4,-1(a5)
    80000dfc:	0585                	addi	a1,a1,1
    80000dfe:	f765                	bnez	a4,80000de6 <strncpy+0xc>
    ;
  while (n-- > 0)
    80000e00:	873e                	mv	a4,a5
    80000e02:	01005b63          	blez	a6,80000e18 <strncpy+0x3e>
    80000e06:	9fb1                	addw	a5,a5,a2
    80000e08:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000e10:	40e786bb          	subw	a3,a5,a4
    80000e14:	fed04be3          	bgtz	a3,80000e0a <strncpy+0x30>
  return os;
}
    80000e18:	60a2                	ld	ra,8(sp)
    80000e1a:	6402                	ld	s0,0(sp)
    80000e1c:	0141                	addi	sp,sp,16
    80000e1e:	8082                	ret

0000000080000e20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000e20:	1141                	addi	sp,sp,-16
    80000e22:	e406                	sd	ra,8(sp)
    80000e24:	e022                	sd	s0,0(sp)
    80000e26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000e28:	02c05363          	blez	a2,80000e4e <safestrcpy+0x2e>
    80000e2c:	fff6069b          	addiw	a3,a2,-1
    80000e30:	1682                	slli	a3,a3,0x20
    80000e32:	9281                	srli	a3,a3,0x20
    80000e34:	96ae                	add	a3,a3,a1
    80000e36:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000e38:	00d58963          	beq	a1,a3,80000e4a <safestrcpy+0x2a>
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	0785                	addi	a5,a5,1
    80000e40:	fff5c703          	lbu	a4,-1(a1)
    80000e44:	fee78fa3          	sb	a4,-1(a5)
    80000e48:	fb65                	bnez	a4,80000e38 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e4a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e4e:	60a2                	ld	ra,8(sp)
    80000e50:	6402                	ld	s0,0(sp)
    80000e52:	0141                	addi	sp,sp,16
    80000e54:	8082                	ret

0000000080000e56 <strlen>:

int
strlen(const char *s)
{
    80000e56:	1141                	addi	sp,sp,-16
    80000e58:	e406                	sd	ra,8(sp)
    80000e5a:	e022                	sd	s0,0(sp)
    80000e5c:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e5e:	00054783          	lbu	a5,0(a0)
    80000e62:	cf91                	beqz	a5,80000e7e <strlen+0x28>
    80000e64:	00150793          	addi	a5,a0,1
    80000e68:	86be                	mv	a3,a5
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff7c703          	lbu	a4,-1(a5)
    80000e70:	ff65                	bnez	a4,80000e68 <strlen+0x12>
    80000e72:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000e76:	60a2                	ld	ra,8(sp)
    80000e78:	6402                	ld	s0,0(sp)
    80000e7a:	0141                	addi	sp,sp,16
    80000e7c:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e7e:	4501                	li	a0,0
    80000e80:	bfdd                	j	80000e76 <strlen+0x20>

0000000080000e82 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e8a:	245000ef          	jal	800018ce <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    started = 1;
  } else {
    while (started == 0)
    80000e8e:	00009717          	auipc	a4,0x9
    80000e92:	40270713          	addi	a4,a4,1026 # 8000a290 <started>
  if (cpuid() == 0) {
    80000e96:	c51d                	beqz	a0,80000ec4 <main+0x42>
    while (started == 0)
    80000e98:	431c                	lw	a5,0(a4)
    80000e9a:	2781                	sext.w	a5,a5
    80000e9c:	dff5                	beqz	a5,80000e98 <main+0x16>
      ;
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80000e9e:	0330000f          	fence	rw,rw
    printk("hart %d starting\n", cpuid());
    80000ea2:	22d000ef          	jal	800018ce <cpuid>
    80000ea6:	85aa                	mv	a1,a0
    80000ea8:	00006517          	auipc	a0,0x6
    80000eac:	1f050513          	addi	a0,a0,496 # 80007098 <etext+0x98>
    80000eb0:	e3eff0ef          	jal	800004ee <printk>
    kvminithart();  // turn on paging
    80000eb4:	080000ef          	jal	80000f34 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000eb8:	570010ef          	jal	80002428 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ebc:	61c040ef          	jal	800054d8 <plicinithart>
  }

  scheduler();
    80000ec0:	6b9000ef          	jal	80001d78 <scheduler>
    consoleinit();
    80000ec4:	d50ff0ef          	jal	80000414 <consoleinit>
    printkinit();
    80000ec8:	98dff0ef          	jal	80000854 <printkinit>
    printk("\n");
    80000ecc:	00006517          	auipc	a0,0x6
    80000ed0:	1ac50513          	addi	a0,a0,428 # 80007078 <etext+0x78>
    80000ed4:	e1aff0ef          	jal	800004ee <printk>
    printk("xv6 kernel is booting\n");
    80000ed8:	00006517          	auipc	a0,0x6
    80000edc:	1a850513          	addi	a0,a0,424 # 80007080 <etext+0x80>
    80000ee0:	e0eff0ef          	jal	800004ee <printk>
    printk("\n");
    80000ee4:	00006517          	auipc	a0,0x6
    80000ee8:	19450513          	addi	a0,a0,404 # 80007078 <etext+0x78>
    80000eec:	e02ff0ef          	jal	800004ee <printk>
    kinit();            // physical page allocator
    80000ef0:	bfdff0ef          	jal	80000aec <kinit>
    kvminit();          // create kernel page table
    80000ef4:	2cc000ef          	jal	800011c0 <kvminit>
    kvminithart();      // turn on paging
    80000ef8:	03c000ef          	jal	80000f34 <kvminithart>
    procinit();         // process table
    80000efc:	11d000ef          	jal	80001818 <procinit>
    trapinit();         // trap vectors
    80000f00:	504010ef          	jal	80002404 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f04:	524010ef          	jal	80002428 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f08:	5b6040ef          	jal	800054be <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f0c:	5cc040ef          	jal	800054d8 <plicinithart>
    binit();            // buffer cache
    80000f10:	3e1010ef          	jal	80002af0 <binit>
    iinit();            // inode table
    80000f14:	132020ef          	jal	80003046 <iinit>
    fileinit();         // file table
    80000f18:	0bc030ef          	jal	80003fd4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1c:	6ac040ef          	jal	800055c8 <virtio_disk_init>
    userinit();         // first user process
    80000f20:	4ad000ef          	jal	80001bcc <userinit>
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80000f24:	0330000f          	fence	rw,rw
    started = 1;
    80000f28:	4785                	li	a5,1
    80000f2a:	00009717          	auipc	a4,0x9
    80000f2e:	36f72323          	sw	a5,870(a4) # 8000a290 <started>
    80000f32:	b779                	j	80000ec0 <main+0x3e>

0000000080000f34 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f34:	1141                	addi	sp,sp,-16
    80000f36:	e406                	sd	ra,8(sp)
    80000f38:	e022                	sd	s0,0(sp)
    80000f3a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f3c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	3587b783          	ld	a5,856(a5) # 8000a298 <kernel_pagetable>
    80000f48:	83b1                	srli	a5,a5,0xc
    80000f4a:	577d                	li	a4,-1
    80000f4c:	177e                	slli	a4,a4,0x3f
    80000f4e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f50:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f54:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f58:	60a2                	ld	ra,8(sp)
    80000f5a:	6402                	ld	s0,0(sp)
    80000f5c:	0141                	addi	sp,sp,16
    80000f5e:	8082                	ret

0000000080000f60 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f60:	7139                	addi	sp,sp,-64
    80000f62:	fc06                	sd	ra,56(sp)
    80000f64:	f822                	sd	s0,48(sp)
    80000f66:	f426                	sd	s1,40(sp)
    80000f68:	f04a                	sd	s2,32(sp)
    80000f6a:	ec4e                	sd	s3,24(sp)
    80000f6c:	e852                	sd	s4,16(sp)
    80000f6e:	e456                	sd	s5,8(sp)
    80000f70:	e05a                	sd	s6,0(sp)
    80000f72:	0080                	addi	s0,sp,64
    80000f74:	84aa                	mv	s1,a0
    80000f76:	89ae                	mv	s3,a1
    80000f78:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80000f7a:	57fd                	li	a5,-1
    80000f7c:	83e9                	srli	a5,a5,0x1a
    80000f7e:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f80:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80000f82:	04b7e263          	bltu	a5,a1,80000fc6 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f86:	0149d933          	srl	s2,s3,s4
    80000f8a:	1ff97913          	andi	s2,s2,511
    80000f8e:	090e                	slli	s2,s2,0x3
    80000f90:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f92:	00093483          	ld	s1,0(s2)
    80000f96:	0014f793          	andi	a5,s1,1
    80000f9a:	cf85                	beqz	a5,80000fd2 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f9c:	80a9                	srli	s1,s1,0xa
    80000f9e:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    80000fa0:	3a5d                	addiw	s4,s4,-9
    80000fa2:	ff5a12e3          	bne	s4,s5,80000f86 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fa6:	00c9d513          	srli	a0,s3,0xc
    80000faa:	1ff57513          	andi	a0,a0,511
    80000fae:	050e                	slli	a0,a0,0x3
    80000fb0:	9526                	add	a0,a0,s1
}
    80000fb2:	70e2                	ld	ra,56(sp)
    80000fb4:	7442                	ld	s0,48(sp)
    80000fb6:	74a2                	ld	s1,40(sp)
    80000fb8:	7902                	ld	s2,32(sp)
    80000fba:	69e2                	ld	s3,24(sp)
    80000fbc:	6a42                	ld	s4,16(sp)
    80000fbe:	6aa2                	ld	s5,8(sp)
    80000fc0:	6b02                	ld	s6,0(sp)
    80000fc2:	6121                	addi	sp,sp,64
    80000fc4:	8082                	ret
    panic("walk");
    80000fc6:	00006517          	auipc	a0,0x6
    80000fca:	0ea50513          	addi	a0,a0,234 # 800070b0 <etext+0xb0>
    80000fce:	84bff0ef          	jal	80000818 <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000fd2:	020b0263          	beqz	s6,80000ff6 <walk+0x96>
    80000fd6:	b4bff0ef          	jal	80000b20 <kalloc>
    80000fda:	84aa                	mv	s1,a0
    80000fdc:	d979                	beqz	a0,80000fb2 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fde:	6605                	lui	a2,0x1
    80000fe0:	4581                	li	a1,0
    80000fe2:	cebff0ef          	jal	80000ccc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fe6:	00c4d793          	srli	a5,s1,0xc
    80000fea:	07aa                	slli	a5,a5,0xa
    80000fec:	0017e793          	ori	a5,a5,1
    80000ff0:	00f93023          	sd	a5,0(s2)
    80000ff4:	b775                	j	80000fa0 <walk+0x40>
        return 0;
    80000ff6:	4501                	li	a0,0
    80000ff8:	bf6d                	j	80000fb2 <walk+0x52>

0000000080000ffa <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000ffa:	57fd                	li	a5,-1
    80000ffc:	83e9                	srli	a5,a5,0x1a
    80000ffe:	00b7f463          	bgeu	a5,a1,80001006 <walkaddr+0xc>
    return 0;
    80001002:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001004:	8082                	ret
{
    80001006:	1141                	addi	sp,sp,-16
    80001008:	e406                	sd	ra,8(sp)
    8000100a:	e022                	sd	s0,0(sp)
    8000100c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000100e:	4601                	li	a2,0
    80001010:	f51ff0ef          	jal	80000f60 <walk>
  if (pte == 0)
    80001014:	c901                	beqz	a0,80001024 <walkaddr+0x2a>
  if ((*pte & PTE_V) == 0)
    80001016:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80001018:	0117f693          	andi	a3,a5,17
    8000101c:	4745                	li	a4,17
    return 0;
    8000101e:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80001020:	00e68663          	beq	a3,a4,8000102c <walkaddr+0x32>
}
    80001024:	60a2                	ld	ra,8(sp)
    80001026:	6402                	ld	s0,0(sp)
    80001028:	0141                	addi	sp,sp,16
    8000102a:	8082                	ret
  pa = PTE2PA(*pte);
    8000102c:	83a9                	srli	a5,a5,0xa
    8000102e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001032:	bfcd                	j	80001024 <walkaddr+0x2a>

0000000080001034 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001034:	715d                	addi	sp,sp,-80
    80001036:	e486                	sd	ra,72(sp)
    80001038:	e0a2                	sd	s0,64(sp)
    8000103a:	fc26                	sd	s1,56(sp)
    8000103c:	f84a                	sd	s2,48(sp)
    8000103e:	f44e                	sd	s3,40(sp)
    80001040:	f052                	sd	s4,32(sp)
    80001042:	ec56                	sd	s5,24(sp)
    80001044:	e85a                	sd	s6,16(sp)
    80001046:	e45e                	sd	s7,8(sp)
    80001048:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    8000104a:	03459793          	slli	a5,a1,0x34
    8000104e:	eba1                	bnez	a5,8000109e <mappages+0x6a>
    80001050:	8a2a                	mv	s4,a0
    80001052:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001054:	03461793          	slli	a5,a2,0x34
    80001058:	eba9                	bnez	a5,800010aa <mappages+0x76>
    panic("mappages: size not aligned");

  if (size == 0)
    8000105a:	ce31                	beqz	a2,800010b6 <mappages+0x82>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000105c:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80001060:	80060613          	addi	a2,a2,-2048
    80001064:	00b60933          	add	s2,a2,a1
  a = va;
    80001068:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000106a:	4b05                	li	s6,1
    8000106c:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80001070:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001072:	865a                	mv	a2,s6
    80001074:	85a6                	mv	a1,s1
    80001076:	8552                	mv	a0,s4
    80001078:	ee9ff0ef          	jal	80000f60 <walk>
    8000107c:	c929                	beqz	a0,800010ce <mappages+0x9a>
    if (*pte & PTE_V)
    8000107e:	611c                	ld	a5,0(a0)
    80001080:	8b85                	andi	a5,a5,1
    80001082:	e3a1                	bnez	a5,800010c2 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001084:	013487b3          	add	a5,s1,s3
    80001088:	83b1                	srli	a5,a5,0xc
    8000108a:	07aa                	slli	a5,a5,0xa
    8000108c:	0157e7b3          	or	a5,a5,s5
    80001090:	0017e793          	ori	a5,a5,1
    80001094:	e11c                	sd	a5,0(a0)
    if (a == last)
    80001096:	05248863          	beq	s1,s2,800010e6 <mappages+0xb2>
    a += PGSIZE;
    8000109a:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000109c:	bfd9                	j	80001072 <mappages+0x3e>
    panic("mappages: va not aligned");
    8000109e:	00006517          	auipc	a0,0x6
    800010a2:	01a50513          	addi	a0,a0,26 # 800070b8 <etext+0xb8>
    800010a6:	f72ff0ef          	jal	80000818 <panic>
    panic("mappages: size not aligned");
    800010aa:	00006517          	auipc	a0,0x6
    800010ae:	02e50513          	addi	a0,a0,46 # 800070d8 <etext+0xd8>
    800010b2:	f66ff0ef          	jal	80000818 <panic>
    panic("mappages: size");
    800010b6:	00006517          	auipc	a0,0x6
    800010ba:	04250513          	addi	a0,a0,66 # 800070f8 <etext+0xf8>
    800010be:	f5aff0ef          	jal	80000818 <panic>
      panic("mappages: remap");
    800010c2:	00006517          	auipc	a0,0x6
    800010c6:	04650513          	addi	a0,a0,70 # 80007108 <etext+0x108>
    800010ca:	f4eff0ef          	jal	80000818 <panic>
      return -1;
    800010ce:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010d0:	60a6                	ld	ra,72(sp)
    800010d2:	6406                	ld	s0,64(sp)
    800010d4:	74e2                	ld	s1,56(sp)
    800010d6:	7942                	ld	s2,48(sp)
    800010d8:	79a2                	ld	s3,40(sp)
    800010da:	7a02                	ld	s4,32(sp)
    800010dc:	6ae2                	ld	s5,24(sp)
    800010de:	6b42                	ld	s6,16(sp)
    800010e0:	6ba2                	ld	s7,8(sp)
    800010e2:	6161                	addi	sp,sp,80
    800010e4:	8082                	ret
  return 0;
    800010e6:	4501                	li	a0,0
    800010e8:	b7e5                	j	800010d0 <mappages+0x9c>

00000000800010ea <kvmmap>:
{
    800010ea:	1141                	addi	sp,sp,-16
    800010ec:	e406                	sd	ra,8(sp)
    800010ee:	e022                	sd	s0,0(sp)
    800010f0:	0800                	addi	s0,sp,16
    800010f2:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010f4:	86b2                	mv	a3,a2
    800010f6:	863e                	mv	a2,a5
    800010f8:	f3dff0ef          	jal	80001034 <mappages>
    800010fc:	e509                	bnez	a0,80001106 <kvmmap+0x1c>
}
    800010fe:	60a2                	ld	ra,8(sp)
    80001100:	6402                	ld	s0,0(sp)
    80001102:	0141                	addi	sp,sp,16
    80001104:	8082                	ret
    panic("kvmmap");
    80001106:	00006517          	auipc	a0,0x6
    8000110a:	01250513          	addi	a0,a0,18 # 80007118 <etext+0x118>
    8000110e:	f0aff0ef          	jal	80000818 <panic>

0000000080001112 <kvmmake>:
{
    80001112:	1101                	addi	sp,sp,-32
    80001114:	ec06                	sd	ra,24(sp)
    80001116:	e822                	sd	s0,16(sp)
    80001118:	e426                	sd	s1,8(sp)
    8000111a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000111c:	a05ff0ef          	jal	80000b20 <kalloc>
    80001120:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001122:	6605                	lui	a2,0x1
    80001124:	4581                	li	a1,0
    80001126:	ba7ff0ef          	jal	80000ccc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	6685                	lui	a3,0x1
    8000112e:	10000637          	lui	a2,0x10000
    80001132:	85b2                	mv	a1,a2
    80001134:	8526                	mv	a0,s1
    80001136:	fb5ff0ef          	jal	800010ea <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000113a:	4719                	li	a4,6
    8000113c:	6685                	lui	a3,0x1
    8000113e:	10001637          	lui	a2,0x10001
    80001142:	85b2                	mv	a1,a2
    80001144:	8526                	mv	a0,s1
    80001146:	fa5ff0ef          	jal	800010ea <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000114a:	4719                	li	a4,6
    8000114c:	040006b7          	lui	a3,0x4000
    80001150:	0c000637          	lui	a2,0xc000
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f93ff0ef          	jal	800010ea <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000115c:	4729                	li	a4,10
    8000115e:	80006697          	auipc	a3,0x80006
    80001162:	ea268693          	addi	a3,a3,-350 # 7000 <_entry-0x7fff9000>
    80001166:	4605                	li	a2,1
    80001168:	067e                	slli	a2,a2,0x1f
    8000116a:	85b2                	mv	a1,a2
    8000116c:	8526                	mv	a0,s1
    8000116e:	f7dff0ef          	jal	800010ea <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001172:	4719                	li	a4,6
    80001174:	00006697          	auipc	a3,0x6
    80001178:	e8c68693          	addi	a3,a3,-372 # 80007000 <etext>
    8000117c:	47c5                	li	a5,17
    8000117e:	07ee                	slli	a5,a5,0x1b
    80001180:	40d786b3          	sub	a3,a5,a3
    80001184:	00006617          	auipc	a2,0x6
    80001188:	e7c60613          	addi	a2,a2,-388 # 80007000 <etext>
    8000118c:	85b2                	mv	a1,a2
    8000118e:	8526                	mv	a0,s1
    80001190:	f5bff0ef          	jal	800010ea <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001194:	4729                	li	a4,10
    80001196:	6685                	lui	a3,0x1
    80001198:	00005617          	auipc	a2,0x5
    8000119c:	e6860613          	addi	a2,a2,-408 # 80006000 <_trampoline>
    800011a0:	040005b7          	lui	a1,0x4000
    800011a4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011a6:	05b2                	slli	a1,a1,0xc
    800011a8:	8526                	mv	a0,s1
    800011aa:	f41ff0ef          	jal	800010ea <kvmmap>
  proc_mapstacks(kpgtbl);
    800011ae:	8526                	mv	a0,s1
    800011b0:	5c4000ef          	jal	80001774 <proc_mapstacks>
}
    800011b4:	8526                	mv	a0,s1
    800011b6:	60e2                	ld	ra,24(sp)
    800011b8:	6442                	ld	s0,16(sp)
    800011ba:	64a2                	ld	s1,8(sp)
    800011bc:	6105                	addi	sp,sp,32
    800011be:	8082                	ret

00000000800011c0 <kvminit>:
{
    800011c0:	1141                	addi	sp,sp,-16
    800011c2:	e406                	sd	ra,8(sp)
    800011c4:	e022                	sd	s0,0(sp)
    800011c6:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011c8:	f4bff0ef          	jal	80001112 <kvmmake>
    800011cc:	00009797          	auipc	a5,0x9
    800011d0:	0ca7b623          	sd	a0,204(a5) # 8000a298 <kernel_pagetable>
}
    800011d4:	60a2                	ld	ra,8(sp)
    800011d6:	6402                	ld	s0,0(sp)
    800011d8:	0141                	addi	sp,sp,16
    800011da:	8082                	ret

00000000800011dc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011dc:	1101                	addi	sp,sp,-32
    800011de:	ec06                	sd	ra,24(sp)
    800011e0:	e822                	sd	s0,16(sp)
    800011e2:	e426                	sd	s1,8(sp)
    800011e4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    800011e6:	93bff0ef          	jal	80000b20 <kalloc>
    800011ea:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800011ec:	c509                	beqz	a0,800011f6 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011ee:	6605                	lui	a2,0x1
    800011f0:	4581                	li	a1,0
    800011f2:	adbff0ef          	jal	80000ccc <memset>
  return pagetable;
}
    800011f6:	8526                	mv	a0,s1
    800011f8:	60e2                	ld	ra,24(sp)
    800011fa:	6442                	ld	s0,16(sp)
    800011fc:	64a2                	ld	s1,8(sp)
    800011fe:	6105                	addi	sp,sp,32
    80001200:	8082                	ret

0000000080001202 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001202:	7139                	addi	sp,sp,-64
    80001204:	fc06                	sd	ra,56(sp)
    80001206:	f822                	sd	s0,48(sp)
    80001208:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    8000120a:	03459793          	slli	a5,a1,0x34
    8000120e:	e38d                	bnez	a5,80001230 <uvmunmap+0x2e>
    80001210:	f04a                	sd	s2,32(sp)
    80001212:	ec4e                	sd	s3,24(sp)
    80001214:	e852                	sd	s4,16(sp)
    80001216:	e456                	sd	s5,8(sp)
    80001218:	e05a                	sd	s6,0(sp)
    8000121a:	8a2a                	mv	s4,a0
    8000121c:	892e                	mv	s2,a1
    8000121e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001220:	0632                	slli	a2,a2,0xc
    80001222:	00b609b3          	add	s3,a2,a1
    80001226:	6b05                	lui	s6,0x1
    80001228:	0535f963          	bgeu	a1,s3,8000127a <uvmunmap+0x78>
    8000122c:	f426                	sd	s1,40(sp)
    8000122e:	a015                	j	80001252 <uvmunmap+0x50>
    80001230:	f426                	sd	s1,40(sp)
    80001232:	f04a                	sd	s2,32(sp)
    80001234:	ec4e                	sd	s3,24(sp)
    80001236:	e852                	sd	s4,16(sp)
    80001238:	e456                	sd	s5,8(sp)
    8000123a:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000123c:	00006517          	auipc	a0,0x6
    80001240:	ee450513          	addi	a0,a0,-284 # 80007120 <etext+0x120>
    80001244:	dd4ff0ef          	jal	80000818 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    80001248:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000124c:	995a                	add	s2,s2,s6
    8000124e:	03397563          	bgeu	s2,s3,80001278 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001252:	4601                	li	a2,0
    80001254:	85ca                	mv	a1,s2
    80001256:	8552                	mv	a0,s4
    80001258:	d09ff0ef          	jal	80000f60 <walk>
    8000125c:	84aa                	mv	s1,a0
    8000125e:	d57d                	beqz	a0,8000124c <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    80001260:	611c                	ld	a5,0(a0)
    80001262:	0017f713          	andi	a4,a5,1
    80001266:	d37d                	beqz	a4,8000124c <uvmunmap+0x4a>
    if (do_free) {
    80001268:	fe0a80e3          	beqz	s5,80001248 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000126c:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    8000126e:	00c79513          	slli	a0,a5,0xc
    80001272:	fc6ff0ef          	jal	80000a38 <kfree>
    80001276:	bfc9                	j	80001248 <uvmunmap+0x46>
    80001278:	74a2                	ld	s1,40(sp)
    8000127a:	7902                	ld	s2,32(sp)
    8000127c:	69e2                	ld	s3,24(sp)
    8000127e:	6a42                	ld	s4,16(sp)
    80001280:	6aa2                	ld	s5,8(sp)
    80001282:	6b02                	ld	s6,0(sp)
  }
}
    80001284:	70e2                	ld	ra,56(sp)
    80001286:	7442                	ld	s0,48(sp)
    80001288:	6121                	addi	sp,sp,64
    8000128a:	8082                	ret

000000008000128c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000128c:	1101                	addi	sp,sp,-32
    8000128e:	ec06                	sd	ra,24(sp)
    80001290:	e822                	sd	s0,16(sp)
    80001292:	e426                	sd	s1,8(sp)
    80001294:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001296:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001298:	00b67d63          	bgeu	a2,a1,800012b2 <uvmdealloc+0x26>
    8000129c:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	00f60733          	add	a4,a2,a5
    800012a6:	76fd                	lui	a3,0xfffff
    800012a8:	8f75                	and	a4,a4,a3
    800012aa:	97ae                	add	a5,a5,a1
    800012ac:	8ff5                	and	a5,a5,a3
    800012ae:	00f76863          	bltu	a4,a5,800012be <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012b2:	8526                	mv	a0,s1
    800012b4:	60e2                	ld	ra,24(sp)
    800012b6:	6442                	ld	s0,16(sp)
    800012b8:	64a2                	ld	s1,8(sp)
    800012ba:	6105                	addi	sp,sp,32
    800012bc:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012be:	8f99                	sub	a5,a5,a4
    800012c0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012c2:	4685                	li	a3,1
    800012c4:	0007861b          	sext.w	a2,a5
    800012c8:	85ba                	mv	a1,a4
    800012ca:	f39ff0ef          	jal	80001202 <uvmunmap>
    800012ce:	b7d5                	j	800012b2 <uvmdealloc+0x26>

00000000800012d0 <uvmalloc>:
  if (newsz < oldsz)
    800012d0:	0ab66163          	bltu	a2,a1,80001372 <uvmalloc+0xa2>
{
    800012d4:	715d                	addi	sp,sp,-80
    800012d6:	e486                	sd	ra,72(sp)
    800012d8:	e0a2                	sd	s0,64(sp)
    800012da:	f84a                	sd	s2,48(sp)
    800012dc:	f052                	sd	s4,32(sp)
    800012de:	ec56                	sd	s5,24(sp)
    800012e0:	e45e                	sd	s7,8(sp)
    800012e2:	0880                	addi	s0,sp,80
    800012e4:	8aaa                	mv	s5,a0
    800012e6:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012e8:	6785                	lui	a5,0x1
    800012ea:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ec:	95be                	add	a1,a1,a5
    800012ee:	77fd                	lui	a5,0xfffff
    800012f0:	00f5f933          	and	s2,a1,a5
    800012f4:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012f6:	08c97063          	bgeu	s2,a2,80001376 <uvmalloc+0xa6>
    800012fa:	fc26                	sd	s1,56(sp)
    800012fc:	f44e                	sd	s3,40(sp)
    800012fe:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    80001300:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001302:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001306:	81bff0ef          	jal	80000b20 <kalloc>
    8000130a:	84aa                	mv	s1,a0
    if (mem == 0) {
    8000130c:	c50d                	beqz	a0,80001336 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000130e:	864e                	mv	a2,s3
    80001310:	4581                	li	a1,0
    80001312:	9bbff0ef          	jal	80000ccc <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001316:	875a                	mv	a4,s6
    80001318:	86a6                	mv	a3,s1
    8000131a:	864e                	mv	a2,s3
    8000131c:	85ca                	mv	a1,s2
    8000131e:	8556                	mv	a0,s5
    80001320:	d15ff0ef          	jal	80001034 <mappages>
    80001324:	e915                	bnez	a0,80001358 <uvmalloc+0x88>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001326:	994e                	add	s2,s2,s3
    80001328:	fd496fe3          	bltu	s2,s4,80001306 <uvmalloc+0x36>
  return newsz;
    8000132c:	8552                	mv	a0,s4
    8000132e:	74e2                	ld	s1,56(sp)
    80001330:	79a2                	ld	s3,40(sp)
    80001332:	6b42                	ld	s6,16(sp)
    80001334:	a811                	j	80001348 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001336:	865e                	mv	a2,s7
    80001338:	85ca                	mv	a1,s2
    8000133a:	8556                	mv	a0,s5
    8000133c:	f51ff0ef          	jal	8000128c <uvmdealloc>
      return 0;
    80001340:	4501                	li	a0,0
    80001342:	74e2                	ld	s1,56(sp)
    80001344:	79a2                	ld	s3,40(sp)
    80001346:	6b42                	ld	s6,16(sp)
}
    80001348:	60a6                	ld	ra,72(sp)
    8000134a:	6406                	ld	s0,64(sp)
    8000134c:	7942                	ld	s2,48(sp)
    8000134e:	7a02                	ld	s4,32(sp)
    80001350:	6ae2                	ld	s5,24(sp)
    80001352:	6ba2                	ld	s7,8(sp)
    80001354:	6161                	addi	sp,sp,80
    80001356:	8082                	ret
      kfree(mem);
    80001358:	8526                	mv	a0,s1
    8000135a:	edeff0ef          	jal	80000a38 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000135e:	865e                	mv	a2,s7
    80001360:	85ca                	mv	a1,s2
    80001362:	8556                	mv	a0,s5
    80001364:	f29ff0ef          	jal	8000128c <uvmdealloc>
      return 0;
    80001368:	4501                	li	a0,0
    8000136a:	74e2                	ld	s1,56(sp)
    8000136c:	79a2                	ld	s3,40(sp)
    8000136e:	6b42                	ld	s6,16(sp)
    80001370:	bfe1                	j	80001348 <uvmalloc+0x78>
    return oldsz;
    80001372:	852e                	mv	a0,a1
}
    80001374:	8082                	ret
  return newsz;
    80001376:	8532                	mv	a0,a2
    80001378:	bfc1                	j	80001348 <uvmalloc+0x78>

000000008000137a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000137a:	7179                	addi	sp,sp,-48
    8000137c:	f406                	sd	ra,40(sp)
    8000137e:	f022                	sd	s0,32(sp)
    80001380:	ec26                	sd	s1,24(sp)
    80001382:	e84a                	sd	s2,16(sp)
    80001384:	e44e                	sd	s3,8(sp)
    80001386:	1800                	addi	s0,sp,48
    80001388:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    8000138a:	84aa                	mv	s1,a0
    8000138c:	6905                	lui	s2,0x1
    8000138e:	992a                	add	s2,s2,a0
    80001390:	a811                	j	800013a4 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    80001392:	00006517          	auipc	a0,0x6
    80001396:	da650513          	addi	a0,a0,-602 # 80007138 <etext+0x138>
    8000139a:	c7eff0ef          	jal	80000818 <panic>
  for (int i = 0; i < 512; i++) {
    8000139e:	04a1                	addi	s1,s1,8
    800013a0:	03248163          	beq	s1,s2,800013c2 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013a4:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013a6:	0017f713          	andi	a4,a5,1
    800013aa:	db75                	beqz	a4,8000139e <freewalk+0x24>
    800013ac:	00e7f713          	andi	a4,a5,14
    800013b0:	f36d                	bnez	a4,80001392 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013b2:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013b4:	00c79513          	slli	a0,a5,0xc
    800013b8:	fc3ff0ef          	jal	8000137a <freewalk>
      pagetable[i] = 0;
    800013bc:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013c0:	bff9                	j	8000139e <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    800013c2:	854e                	mv	a0,s3
    800013c4:	e74ff0ef          	jal	80000a38 <kfree>
}
    800013c8:	70a2                	ld	ra,40(sp)
    800013ca:	7402                	ld	s0,32(sp)
    800013cc:	64e2                	ld	s1,24(sp)
    800013ce:	6942                	ld	s2,16(sp)
    800013d0:	69a2                	ld	s3,8(sp)
    800013d2:	6145                	addi	sp,sp,48
    800013d4:	8082                	ret

00000000800013d6 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013d6:	1101                	addi	sp,sp,-32
    800013d8:	ec06                	sd	ra,24(sp)
    800013da:	e822                	sd	s0,16(sp)
    800013dc:	e426                	sd	s1,8(sp)
    800013de:	1000                	addi	s0,sp,32
    800013e0:	84aa                	mv	s1,a0
  if (sz > 0)
    800013e2:	e989                	bnez	a1,800013f4 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    800013e4:	8526                	mv	a0,s1
    800013e6:	f95ff0ef          	jal	8000137a <freewalk>
}
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	addi	sp,sp,32
    800013f2:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800013f4:	6785                	lui	a5,0x1
    800013f6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013f8:	95be                	add	a1,a1,a5
    800013fa:	4685                	li	a3,1
    800013fc:	00c5d613          	srli	a2,a1,0xc
    80001400:	4581                	li	a1,0
    80001402:	e01ff0ef          	jal	80001202 <uvmunmap>
    80001406:	bff9                	j	800013e4 <uvmfree+0xe>

0000000080001408 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001408:	ca59                	beqz	a2,8000149e <uvmcopy+0x96>
{
    8000140a:	715d                	addi	sp,sp,-80
    8000140c:	e486                	sd	ra,72(sp)
    8000140e:	e0a2                	sd	s0,64(sp)
    80001410:	fc26                	sd	s1,56(sp)
    80001412:	f84a                	sd	s2,48(sp)
    80001414:	f44e                	sd	s3,40(sp)
    80001416:	f052                	sd	s4,32(sp)
    80001418:	ec56                	sd	s5,24(sp)
    8000141a:	e85a                	sd	s6,16(sp)
    8000141c:	e45e                	sd	s7,8(sp)
    8000141e:	0880                	addi	s0,sp,80
    80001420:	8b2a                	mv	s6,a0
    80001422:	8bae                	mv	s7,a1
    80001424:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001426:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001428:	6a05                	lui	s4,0x1
    8000142a:	a021                	j	80001432 <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    8000142c:	94d2                	add	s1,s1,s4
    8000142e:	0554fc63          	bgeu	s1,s5,80001486 <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    80001432:	4601                	li	a2,0
    80001434:	85a6                	mv	a1,s1
    80001436:	855a                	mv	a0,s6
    80001438:	b29ff0ef          	jal	80000f60 <walk>
    8000143c:	d965                	beqz	a0,8000142c <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    8000143e:	00053983          	ld	s3,0(a0)
    80001442:	0019f793          	andi	a5,s3,1
    80001446:	d3fd                	beqz	a5,8000142c <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    80001448:	ed8ff0ef          	jal	80000b20 <kalloc>
    8000144c:	892a                	mv	s2,a0
    8000144e:	c11d                	beqz	a0,80001474 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    80001450:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    80001454:	8652                	mv	a2,s4
    80001456:	05b2                	slli	a1,a1,0xc
    80001458:	8d5ff0ef          	jal	80000d2c <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    8000145c:	3ff9f713          	andi	a4,s3,1023
    80001460:	86ca                	mv	a3,s2
    80001462:	8652                	mv	a2,s4
    80001464:	85a6                	mv	a1,s1
    80001466:	855e                	mv	a0,s7
    80001468:	bcdff0ef          	jal	80001034 <mappages>
    8000146c:	d161                	beqz	a0,8000142c <uvmcopy+0x24>
      kfree(mem);
    8000146e:	854a                	mv	a0,s2
    80001470:	dc8ff0ef          	jal	80000a38 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001474:	4685                	li	a3,1
    80001476:	00c4d613          	srli	a2,s1,0xc
    8000147a:	4581                	li	a1,0
    8000147c:	855e                	mv	a0,s7
    8000147e:	d85ff0ef          	jal	80001202 <uvmunmap>
  return -1;
    80001482:	557d                	li	a0,-1
    80001484:	a011                	j	80001488 <uvmcopy+0x80>
  return 0;
    80001486:	4501                	li	a0,0
}
    80001488:	60a6                	ld	ra,72(sp)
    8000148a:	6406                	ld	s0,64(sp)
    8000148c:	74e2                	ld	s1,56(sp)
    8000148e:	7942                	ld	s2,48(sp)
    80001490:	79a2                	ld	s3,40(sp)
    80001492:	7a02                	ld	s4,32(sp)
    80001494:	6ae2                	ld	s5,24(sp)
    80001496:	6b42                	ld	s6,16(sp)
    80001498:	6ba2                	ld	s7,8(sp)
    8000149a:	6161                	addi	sp,sp,80
    8000149c:	8082                	ret
  return 0;
    8000149e:	4501                	li	a0,0
}
    800014a0:	8082                	ret

00000000800014a2 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014a2:	1141                	addi	sp,sp,-16
    800014a4:	e406                	sd	ra,8(sp)
    800014a6:	e022                	sd	s0,0(sp)
    800014a8:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800014aa:	4601                	li	a2,0
    800014ac:	ab5ff0ef          	jal	80000f60 <walk>
  if (pte == 0)
    800014b0:	c901                	beqz	a0,800014c0 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014b2:	611c                	ld	a5,0(a0)
    800014b4:	9bbd                	andi	a5,a5,-17
    800014b6:	e11c                	sd	a5,0(a0)
}
    800014b8:	60a2                	ld	ra,8(sp)
    800014ba:	6402                	ld	s0,0(sp)
    800014bc:	0141                	addi	sp,sp,16
    800014be:	8082                	ret
    panic("uvmclear");
    800014c0:	00006517          	auipc	a0,0x6
    800014c4:	c8850513          	addi	a0,a0,-888 # 80007148 <etext+0x148>
    800014c8:	b50ff0ef          	jal	80000818 <panic>

00000000800014cc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0) {
    800014cc:	cac5                	beqz	a3,8000157c <copyinstr+0xb0>
{
    800014ce:	715d                	addi	sp,sp,-80
    800014d0:	e486                	sd	ra,72(sp)
    800014d2:	e0a2                	sd	s0,64(sp)
    800014d4:	fc26                	sd	s1,56(sp)
    800014d6:	f84a                	sd	s2,48(sp)
    800014d8:	f44e                	sd	s3,40(sp)
    800014da:	f052                	sd	s4,32(sp)
    800014dc:	ec56                	sd	s5,24(sp)
    800014de:	e85a                	sd	s6,16(sp)
    800014e0:	e45e                	sd	s7,8(sp)
    800014e2:	0880                	addi	s0,sp,80
    800014e4:	8aaa                	mv	s5,a0
    800014e6:	84ae                	mv	s1,a1
    800014e8:	8bb2                	mv	s7,a2
    800014ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800014ec:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014ee:	6a05                	lui	s4,0x1
    800014f0:	a82d                	j	8000152a <copyinstr+0x5e>
      n = max;

    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0) {
      if (*p == '\0') {
        *dst = '\0';
    800014f2:	00078023          	sb	zero,0(a5)
        got_null = 1;
    800014f6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null) {
    800014f8:	0017c793          	xori	a5,a5,1
    800014fc:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001500:	60a6                	ld	ra,72(sp)
    80001502:	6406                	ld	s0,64(sp)
    80001504:	74e2                	ld	s1,56(sp)
    80001506:	7942                	ld	s2,48(sp)
    80001508:	79a2                	ld	s3,40(sp)
    8000150a:	7a02                	ld	s4,32(sp)
    8000150c:	6ae2                	ld	s5,24(sp)
    8000150e:	6b42                	ld	s6,16(sp)
    80001510:	6ba2                	ld	s7,8(sp)
    80001512:	6161                	addi	sp,sp,80
    80001514:	8082                	ret
    80001516:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    8000151a:	9726                	add	a4,a4,s1
      --max;
    8000151c:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001520:	01490bb3          	add	s7,s2,s4
  while (got_null == 0 && max > 0) {
    80001524:	04e58463          	beq	a1,a4,8000156c <copyinstr+0xa0>
{
    80001528:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    8000152a:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000152e:	85ca                	mv	a1,s2
    80001530:	8556                	mv	a0,s5
    80001532:	ac9ff0ef          	jal	80000ffa <walkaddr>
    if (pa0 == 0)
    80001536:	cd0d                	beqz	a0,80001570 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001538:	417906b3          	sub	a3,s2,s7
    8000153c:	96d2                	add	a3,a3,s4
    if (n > max)
    8000153e:	00d9f363          	bgeu	s3,a3,80001544 <copyinstr+0x78>
    80001542:	86ce                	mv	a3,s3
    while (n > 0) {
    80001544:	ca85                	beqz	a3,80001574 <copyinstr+0xa8>
    char *p = (char *)(pa0 + (srcva - va0));
    80001546:	01750633          	add	a2,a0,s7
    8000154a:	41260633          	sub	a2,a2,s2
    8000154e:	87a6                	mv	a5,s1
      if (*p == '\0') {
    80001550:	8e05                	sub	a2,a2,s1
    while (n > 0) {
    80001552:	96a6                	add	a3,a3,s1
    80001554:	85be                	mv	a1,a5
      if (*p == '\0') {
    80001556:	00f60733          	add	a4,a2,a5
    8000155a:	00074703          	lbu	a4,0(a4)
    8000155e:	db51                	beqz	a4,800014f2 <copyinstr+0x26>
        *dst = *p;
    80001560:	00e78023          	sb	a4,0(a5)
      dst++;
    80001564:	0785                	addi	a5,a5,1
    while (n > 0) {
    80001566:	fed797e3          	bne	a5,a3,80001554 <copyinstr+0x88>
    8000156a:	b775                	j	80001516 <copyinstr+0x4a>
    8000156c:	4781                	li	a5,0
    8000156e:	b769                	j	800014f8 <copyinstr+0x2c>
      return -1;
    80001570:	557d                	li	a0,-1
    80001572:	b779                	j	80001500 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    80001574:	6b85                	lui	s7,0x1
    80001576:	9bca                	add	s7,s7,s2
    80001578:	87a6                	mv	a5,s1
    8000157a:	b77d                	j	80001528 <copyinstr+0x5c>
  int got_null = 0;
    8000157c:	4781                	li	a5,0
  if (got_null) {
    8000157e:	0017c793          	xori	a5,a5,1
    80001582:	40f0053b          	negw	a0,a5
}
    80001586:	8082                	ret

0000000080001588 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001588:	1141                	addi	sp,sp,-16
    8000158a:	e406                	sd	ra,8(sp)
    8000158c:	e022                	sd	s0,0(sp)
    8000158e:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001590:	4601                	li	a2,0
    80001592:	9cfff0ef          	jal	80000f60 <walk>
  if (pte == 0) {
    80001596:	c119                	beqz	a0,8000159c <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    80001598:	6108                	ld	a0,0(a0)
    8000159a:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    8000159c:	60a2                	ld	ra,8(sp)
    8000159e:	6402                	ld	s0,0(sp)
    800015a0:	0141                	addi	sp,sp,16
    800015a2:	8082                	ret

00000000800015a4 <vmfault>:
{
    800015a4:	7179                	addi	sp,sp,-48
    800015a6:	f406                	sd	ra,40(sp)
    800015a8:	f022                	sd	s0,32(sp)
    800015aa:	e84a                	sd	s2,16(sp)
    800015ac:	e44e                	sd	s3,8(sp)
    800015ae:	1800                	addi	s0,sp,48
    800015b0:	89aa                	mv	s3,a0
    800015b2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015b4:	34e000ef          	jal	80001902 <myproc>
  if (va >= p->sz)
    800015b8:	653c                	ld	a5,72(a0)
    800015ba:	00f96a63          	bltu	s2,a5,800015ce <vmfault+0x2a>
    return 0;
    800015be:	4981                	li	s3,0
}
    800015c0:	854e                	mv	a0,s3
    800015c2:	70a2                	ld	ra,40(sp)
    800015c4:	7402                	ld	s0,32(sp)
    800015c6:	6942                	ld	s2,16(sp)
    800015c8:	69a2                	ld	s3,8(sp)
    800015ca:	6145                	addi	sp,sp,48
    800015cc:	8082                	ret
    800015ce:	ec26                	sd	s1,24(sp)
    800015d0:	e052                	sd	s4,0(sp)
    800015d2:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    800015d4:	77fd                	lui	a5,0xfffff
    800015d6:	00f97a33          	and	s4,s2,a5
  if (ismapped(pagetable, va)) {
    800015da:	85d2                	mv	a1,s4
    800015dc:	854e                	mv	a0,s3
    800015de:	fabff0ef          	jal	80001588 <ismapped>
    return 0;
    800015e2:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    800015e4:	c501                	beqz	a0,800015ec <vmfault+0x48>
    800015e6:	64e2                	ld	s1,24(sp)
    800015e8:	6a02                	ld	s4,0(sp)
    800015ea:	bfd9                	j	800015c0 <vmfault+0x1c>
  mem = (uint64)kalloc();
    800015ec:	d34ff0ef          	jal	80000b20 <kalloc>
    800015f0:	892a                	mv	s2,a0
  if (mem == 0)
    800015f2:	c905                	beqz	a0,80001622 <vmfault+0x7e>
  mem = (uint64)kalloc();
    800015f4:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    800015f6:	6605                	lui	a2,0x1
    800015f8:	4581                	li	a1,0
    800015fa:	ed2ff0ef          	jal	80000ccc <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    800015fe:	4759                	li	a4,22
    80001600:	86ca                	mv	a3,s2
    80001602:	6605                	lui	a2,0x1
    80001604:	85d2                	mv	a1,s4
    80001606:	68a8                	ld	a0,80(s1)
    80001608:	a2dff0ef          	jal	80001034 <mappages>
    8000160c:	e501                	bnez	a0,80001614 <vmfault+0x70>
    8000160e:	64e2                	ld	s1,24(sp)
    80001610:	6a02                	ld	s4,0(sp)
    80001612:	b77d                	j	800015c0 <vmfault+0x1c>
    kfree((void *)mem);
    80001614:	854a                	mv	a0,s2
    80001616:	c22ff0ef          	jal	80000a38 <kfree>
    return 0;
    8000161a:	4981                	li	s3,0
    8000161c:	64e2                	ld	s1,24(sp)
    8000161e:	6a02                	ld	s4,0(sp)
    80001620:	b745                	j	800015c0 <vmfault+0x1c>
    80001622:	64e2                	ld	s1,24(sp)
    80001624:	6a02                	ld	s4,0(sp)
    80001626:	bf69                	j	800015c0 <vmfault+0x1c>

0000000080001628 <copyout>:
  while (len > 0) {
    80001628:	cad1                	beqz	a3,800016bc <copyout+0x94>
{
    8000162a:	711d                	addi	sp,sp,-96
    8000162c:	ec86                	sd	ra,88(sp)
    8000162e:	e8a2                	sd	s0,80(sp)
    80001630:	e4a6                	sd	s1,72(sp)
    80001632:	e0ca                	sd	s2,64(sp)
    80001634:	fc4e                	sd	s3,56(sp)
    80001636:	f852                	sd	s4,48(sp)
    80001638:	f456                	sd	s5,40(sp)
    8000163a:	f05a                	sd	s6,32(sp)
    8000163c:	ec5e                	sd	s7,24(sp)
    8000163e:	e862                	sd	s8,16(sp)
    80001640:	e466                	sd	s9,8(sp)
    80001642:	e06a                	sd	s10,0(sp)
    80001644:	1080                	addi	s0,sp,96
    80001646:	8baa                	mv	s7,a0
    80001648:	8a2e                	mv	s4,a1
    8000164a:	8b32                	mv	s6,a2
    8000164c:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000164e:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    80001650:	5cfd                	li	s9,-1
    80001652:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001656:	6c05                	lui	s8,0x1
    80001658:	a005                	j	80001678 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000165a:	409a0533          	sub	a0,s4,s1
    8000165e:	0009061b          	sext.w	a2,s2
    80001662:	85da                	mv	a1,s6
    80001664:	954e                	add	a0,a0,s3
    80001666:	ec6ff0ef          	jal	80000d2c <memmove>
    len -= n;
    8000166a:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000166e:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    80001670:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    80001674:	040a8263          	beqz	s5,800016b8 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80001678:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    8000167c:	049ce263          	bltu	s9,s1,800016c0 <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    80001680:	85a6                	mv	a1,s1
    80001682:	855e                	mv	a0,s7
    80001684:	977ff0ef          	jal	80000ffa <walkaddr>
    80001688:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    8000168a:	e901                	bnez	a0,8000169a <copyout+0x72>
      if ((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000168c:	4601                	li	a2,0
    8000168e:	85a6                	mv	a1,s1
    80001690:	855e                	mv	a0,s7
    80001692:	f13ff0ef          	jal	800015a4 <vmfault>
    80001696:	89aa                	mv	s3,a0
    80001698:	c139                	beqz	a0,800016de <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    8000169a:	4601                	li	a2,0
    8000169c:	85a6                	mv	a1,s1
    8000169e:	855e                	mv	a0,s7
    800016a0:	8c1ff0ef          	jal	80000f60 <walk>
    if ((*pte & PTE_W) == 0)
    800016a4:	611c                	ld	a5,0(a0)
    800016a6:	8b91                	andi	a5,a5,4
    800016a8:	cf8d                	beqz	a5,800016e2 <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016aa:	41448933          	sub	s2,s1,s4
    800016ae:	9962                	add	s2,s2,s8
    if (n > len)
    800016b0:	fb2af5e3          	bgeu	s5,s2,8000165a <copyout+0x32>
    800016b4:	8956                	mv	s2,s5
    800016b6:	b755                	j	8000165a <copyout+0x32>
  return 0;
    800016b8:	4501                	li	a0,0
    800016ba:	a021                	j	800016c2 <copyout+0x9a>
    800016bc:	4501                	li	a0,0
}
    800016be:	8082                	ret
      return -1;
    800016c0:	557d                	li	a0,-1
}
    800016c2:	60e6                	ld	ra,88(sp)
    800016c4:	6446                	ld	s0,80(sp)
    800016c6:	64a6                	ld	s1,72(sp)
    800016c8:	6906                	ld	s2,64(sp)
    800016ca:	79e2                	ld	s3,56(sp)
    800016cc:	7a42                	ld	s4,48(sp)
    800016ce:	7aa2                	ld	s5,40(sp)
    800016d0:	7b02                	ld	s6,32(sp)
    800016d2:	6be2                	ld	s7,24(sp)
    800016d4:	6c42                	ld	s8,16(sp)
    800016d6:	6ca2                	ld	s9,8(sp)
    800016d8:	6d02                	ld	s10,0(sp)
    800016da:	6125                	addi	sp,sp,96
    800016dc:	8082                	ret
        return -1;
    800016de:	557d                	li	a0,-1
    800016e0:	b7cd                	j	800016c2 <copyout+0x9a>
      return -1;
    800016e2:	557d                	li	a0,-1
    800016e4:	bff9                	j	800016c2 <copyout+0x9a>

00000000800016e6 <copyin>:
  while (len > 0) {
    800016e6:	c6c9                	beqz	a3,80001770 <copyin+0x8a>
{
    800016e8:	715d                	addi	sp,sp,-80
    800016ea:	e486                	sd	ra,72(sp)
    800016ec:	e0a2                	sd	s0,64(sp)
    800016ee:	fc26                	sd	s1,56(sp)
    800016f0:	f84a                	sd	s2,48(sp)
    800016f2:	f44e                	sd	s3,40(sp)
    800016f4:	f052                	sd	s4,32(sp)
    800016f6:	ec56                	sd	s5,24(sp)
    800016f8:	e85a                	sd	s6,16(sp)
    800016fa:	e45e                	sd	s7,8(sp)
    800016fc:	e062                	sd	s8,0(sp)
    800016fe:	0880                	addi	s0,sp,80
    80001700:	8baa                	mv	s7,a0
    80001702:	8aae                	mv	s5,a1
    80001704:	8932                	mv	s2,a2
    80001706:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001708:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000170a:	6b05                	lui	s6,0x1
    8000170c:	a035                	j	80001738 <copyin+0x52>
    8000170e:	412984b3          	sub	s1,s3,s2
    80001712:	94da                	add	s1,s1,s6
    if (n > len)
    80001714:	009a7363          	bgeu	s4,s1,8000171a <copyin+0x34>
    80001718:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	413905b3          	sub	a1,s2,s3
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	95aa                	add	a1,a1,a0
    80001724:	8556                	mv	a0,s5
    80001726:	e06ff0ef          	jal	80000d2c <memmove>
    len -= n;
    8000172a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000172e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001730:	01698933          	add	s2,s3,s6
  while (len > 0) {
    80001734:	020a0163          	beqz	s4,80001756 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001738:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000173c:	85ce                	mv	a1,s3
    8000173e:	855e                	mv	a0,s7
    80001740:	8bbff0ef          	jal	80000ffa <walkaddr>
    if (pa0 == 0) {
    80001744:	f569                	bnez	a0,8000170e <copyin+0x28>
      if ((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001746:	4601                	li	a2,0
    80001748:	85ce                	mv	a1,s3
    8000174a:	855e                	mv	a0,s7
    8000174c:	e59ff0ef          	jal	800015a4 <vmfault>
    80001750:	fd5d                	bnez	a0,8000170e <copyin+0x28>
        return -1;
    80001752:	557d                	li	a0,-1
    80001754:	a011                	j	80001758 <copyin+0x72>
  return 0;
    80001756:	4501                	li	a0,0
}
    80001758:	60a6                	ld	ra,72(sp)
    8000175a:	6406                	ld	s0,64(sp)
    8000175c:	74e2                	ld	s1,56(sp)
    8000175e:	7942                	ld	s2,48(sp)
    80001760:	79a2                	ld	s3,40(sp)
    80001762:	7a02                	ld	s4,32(sp)
    80001764:	6ae2                	ld	s5,24(sp)
    80001766:	6b42                	ld	s6,16(sp)
    80001768:	6ba2                	ld	s7,8(sp)
    8000176a:	6c02                	ld	s8,0(sp)
    8000176c:	6161                	addi	sp,sp,80
    8000176e:	8082                	ret
  return 0;
    80001770:	4501                	li	a0,0
}
    80001772:	8082                	ret

0000000080001774 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001774:	715d                	addi	sp,sp,-80
    80001776:	e486                	sd	ra,72(sp)
    80001778:	e0a2                	sd	s0,64(sp)
    8000177a:	fc26                	sd	s1,56(sp)
    8000177c:	f84a                	sd	s2,48(sp)
    8000177e:	f44e                	sd	s3,40(sp)
    80001780:	f052                	sd	s4,32(sp)
    80001782:	ec56                	sd	s5,24(sp)
    80001784:	e85a                	sd	s6,16(sp)
    80001786:	e45e                	sd	s7,8(sp)
    80001788:	e062                	sd	s8,0(sp)
    8000178a:	0880                	addi	s0,sp,80
    8000178c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000178e:	00011497          	auipc	s1,0x11
    80001792:	04a48493          	addi	s1,s1,74 # 800127d8 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001796:	8c26                	mv	s8,s1
    80001798:	000a57b7          	lui	a5,0xa5
    8000179c:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800017a0:	07b2                	slli	a5,a5,0xc
    800017a2:	fa578793          	addi	a5,a5,-91
    800017a6:	4fa50937          	lui	s2,0x4fa50
    800017aa:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800017ae:	1902                	slli	s2,s2,0x20
    800017b0:	993e                	add	s2,s2,a5
    800017b2:	040009b7          	lui	s3,0x4000
    800017b6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017b8:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017ba:	4b99                	li	s7,6
    800017bc:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    800017be:	00017a97          	auipc	s5,0x17
    800017c2:	a1aa8a93          	addi	s5,s5,-1510 # 800181d8 <tickslock>
    char *pa = kalloc();
    800017c6:	b5aff0ef          	jal	80000b20 <kalloc>
    800017ca:	862a                	mv	a2,a0
    if (pa == 0)
    800017cc:	c121                	beqz	a0,8000180c <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    800017ce:	418485b3          	sub	a1,s1,s8
    800017d2:	858d                	srai	a1,a1,0x3
    800017d4:	032585b3          	mul	a1,a1,s2
    800017d8:	05b6                	slli	a1,a1,0xd
    800017da:	6789                	lui	a5,0x2
    800017dc:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017de:	875e                	mv	a4,s7
    800017e0:	86da                	mv	a3,s6
    800017e2:	40b985b3          	sub	a1,s3,a1
    800017e6:	8552                	mv	a0,s4
    800017e8:	903ff0ef          	jal	800010ea <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017ec:	16848493          	addi	s1,s1,360
    800017f0:	fd549be3          	bne	s1,s5,800017c6 <proc_mapstacks+0x52>
  }
}
    800017f4:	60a6                	ld	ra,72(sp)
    800017f6:	6406                	ld	s0,64(sp)
    800017f8:	74e2                	ld	s1,56(sp)
    800017fa:	7942                	ld	s2,48(sp)
    800017fc:	79a2                	ld	s3,40(sp)
    800017fe:	7a02                	ld	s4,32(sp)
    80001800:	6ae2                	ld	s5,24(sp)
    80001802:	6b42                	ld	s6,16(sp)
    80001804:	6ba2                	ld	s7,8(sp)
    80001806:	6c02                	ld	s8,0(sp)
    80001808:	6161                	addi	sp,sp,80
    8000180a:	8082                	ret
      panic("kalloc");
    8000180c:	00006517          	auipc	a0,0x6
    80001810:	94c50513          	addi	a0,a0,-1716 # 80007158 <etext+0x158>
    80001814:	804ff0ef          	jal	80000818 <panic>

0000000080001818 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001818:	7139                	addi	sp,sp,-64
    8000181a:	fc06                	sd	ra,56(sp)
    8000181c:	f822                	sd	s0,48(sp)
    8000181e:	f426                	sd	s1,40(sp)
    80001820:	f04a                	sd	s2,32(sp)
    80001822:	ec4e                	sd	s3,24(sp)
    80001824:	e852                	sd	s4,16(sp)
    80001826:	e456                	sd	s5,8(sp)
    80001828:	e05a                	sd	s6,0(sp)
    8000182a:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    8000182c:	00006597          	auipc	a1,0x6
    80001830:	93458593          	addi	a1,a1,-1740 # 80007160 <etext+0x160>
    80001834:	00011517          	auipc	a0,0x11
    80001838:	b7450513          	addi	a0,a0,-1164 # 800123a8 <pid_lock>
    8000183c:	b3eff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001840:	00006597          	auipc	a1,0x6
    80001844:	92858593          	addi	a1,a1,-1752 # 80007168 <etext+0x168>
    80001848:	00011517          	auipc	a0,0x11
    8000184c:	b7850513          	addi	a0,a0,-1160 # 800123c0 <wait_lock>
    80001850:	b2aff0ef          	jal	80000b7a <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001854:	00011497          	auipc	s1,0x11
    80001858:	f8448493          	addi	s1,s1,-124 # 800127d8 <proc>
    initlock(&p->lock, "proc");
    8000185c:	00006b17          	auipc	s6,0x6
    80001860:	91cb0b13          	addi	s6,s6,-1764 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001864:	8aa6                	mv	s5,s1
    80001866:	000a57b7          	lui	a5,0xa5
    8000186a:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    8000186e:	07b2                	slli	a5,a5,0xc
    80001870:	fa578793          	addi	a5,a5,-91
    80001874:	4fa50937          	lui	s2,0x4fa50
    80001878:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    8000187c:	1902                	slli	s2,s2,0x20
    8000187e:	993e                	add	s2,s2,a5
    80001880:	040009b7          	lui	s3,0x4000
    80001884:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001886:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001888:	00017a17          	auipc	s4,0x17
    8000188c:	950a0a13          	addi	s4,s4,-1712 # 800181d8 <tickslock>
    initlock(&p->lock, "proc");
    80001890:	85da                	mv	a1,s6
    80001892:	8526                	mv	a0,s1
    80001894:	ae6ff0ef          	jal	80000b7a <initlock>
    p->state = UNUSED;
    80001898:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000189c:	415487b3          	sub	a5,s1,s5
    800018a0:	878d                	srai	a5,a5,0x3
    800018a2:	032787b3          	mul	a5,a5,s2
    800018a6:	07b6                	slli	a5,a5,0xd
    800018a8:	6709                	lui	a4,0x2
    800018aa:	9fb9                	addw	a5,a5,a4
    800018ac:	40f987b3          	sub	a5,s3,a5
    800018b0:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018b2:	16848493          	addi	s1,s1,360
    800018b6:	fd449de3          	bne	s1,s4,80001890 <procinit+0x78>
  }
}
    800018ba:	70e2                	ld	ra,56(sp)
    800018bc:	7442                	ld	s0,48(sp)
    800018be:	74a2                	ld	s1,40(sp)
    800018c0:	7902                	ld	s2,32(sp)
    800018c2:	69e2                	ld	s3,24(sp)
    800018c4:	6a42                	ld	s4,16(sp)
    800018c6:	6aa2                	ld	s5,8(sp)
    800018c8:	6b02                	ld	s6,0(sp)
    800018ca:	6121                	addi	sp,sp,64
    800018cc:	8082                	ret

00000000800018ce <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018ce:	1141                	addi	sp,sp,-16
    800018d0:	e406                	sd	ra,8(sp)
    800018d2:	e022                	sd	s0,0(sp)
    800018d4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    800018d6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018d8:	2501                	sext.w	a0,a0
    800018da:	60a2                	ld	ra,8(sp)
    800018dc:	6402                	ld	s0,0(sp)
    800018de:	0141                	addi	sp,sp,16
    800018e0:	8082                	ret

00000000800018e2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800018e2:	1141                	addi	sp,sp,-16
    800018e4:	e406                	sd	ra,8(sp)
    800018e6:	e022                	sd	s0,0(sp)
    800018e8:	0800                	addi	s0,sp,16
    800018ea:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ec:	2781                	sext.w	a5,a5
    800018ee:	079e                	slli	a5,a5,0x7
  return c;
}
    800018f0:	00011517          	auipc	a0,0x11
    800018f4:	ae850513          	addi	a0,a0,-1304 # 800123d8 <cpus>
    800018f8:	953e                	add	a0,a0,a5
    800018fa:	60a2                	ld	ra,8(sp)
    800018fc:	6402                	ld	s0,0(sp)
    800018fe:	0141                	addi	sp,sp,16
    80001900:	8082                	ret

0000000080001902 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001902:	1101                	addi	sp,sp,-32
    80001904:	ec06                	sd	ra,24(sp)
    80001906:	e822                	sd	s0,16(sp)
    80001908:	e426                	sd	s1,8(sp)
    8000190a:	1000                	addi	s0,sp,32
  push_off();
    8000190c:	ab4ff0ef          	jal	80000bc0 <push_off>
    80001910:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001912:	2781                	sext.w	a5,a5
    80001914:	079e                	slli	a5,a5,0x7
    80001916:	00011717          	auipc	a4,0x11
    8000191a:	a9270713          	addi	a4,a4,-1390 # 800123a8 <pid_lock>
    8000191e:	97ba                	add	a5,a5,a4
    80001920:	7b9c                	ld	a5,48(a5)
    80001922:	84be                	mv	s1,a5
  pop_off();
    80001924:	b20ff0ef          	jal	80000c44 <pop_off>
  return p;
}
    80001928:	8526                	mv	a0,s1
    8000192a:	60e2                	ld	ra,24(sp)
    8000192c:	6442                	ld	s0,16(sp)
    8000192e:	64a2                	ld	s1,8(sp)
    80001930:	6105                	addi	sp,sp,32
    80001932:	8082                	ret

0000000080001934 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001934:	7179                	addi	sp,sp,-48
    80001936:	f406                	sd	ra,40(sp)
    80001938:	f022                	sd	s0,32(sp)
    8000193a:	ec26                	sd	s1,24(sp)
    8000193c:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000193e:	fc5ff0ef          	jal	80001902 <myproc>
    80001942:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001944:	b50ff0ef          	jal	80000c94 <release>

  if (first) {
    80001948:	00009797          	auipc	a5,0x9
    8000194c:	9087a783          	lw	a5,-1784(a5) # 8000a250 <first.1>
    80001950:	cf95                	beqz	a5,8000198c <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001952:	4505                	li	a0,1
    80001954:	3af010ef          	jal	80003502 <fsinit>

    first = 0;
    80001958:	00009797          	auipc	a5,0x9
    8000195c:	8e07ac23          	sw	zero,-1800(a5) # 8000a250 <first.1>
    // ensure other cores see first=0.
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80001960:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001964:	00006797          	auipc	a5,0x6
    80001968:	81c78793          	addi	a5,a5,-2020 # 80007180 <etext+0x180>
    8000196c:	fcf43823          	sd	a5,-48(s0)
    80001970:	fc043c23          	sd	zero,-40(s0)
    80001974:	fd040593          	addi	a1,s0,-48
    80001978:	853e                	mv	a0,a5
    8000197a:	56f020ef          	jal	800046e8 <kexec>
    8000197e:	6cbc                	ld	a5,88(s1)
    80001980:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001982:	6cbc                	ld	a5,88(s1)
    80001984:	7bb8                	ld	a4,112(a5)
    80001986:	57fd                	li	a5,-1
    80001988:	02f70d63          	beq	a4,a5,800019c2 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000198c:	2b9000ef          	jal	80002444 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001990:	68a8                	ld	a0,80(s1)
    80001992:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001994:	04000737          	lui	a4,0x4000
    80001998:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000199a:	0732                	slli	a4,a4,0xc
    8000199c:	00004797          	auipc	a5,0x4
    800019a0:	70078793          	addi	a5,a5,1792 # 8000609c <userret>
    800019a4:	00004697          	auipc	a3,0x4
    800019a8:	65c68693          	addi	a3,a3,1628 # 80006000 <_trampoline>
    800019ac:	8f95                	sub	a5,a5,a3
    800019ae:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019b0:	577d                	li	a4,-1
    800019b2:	177e                	slli	a4,a4,0x3f
    800019b4:	8d59                	or	a0,a0,a4
    800019b6:	9782                	jalr	a5
}
    800019b8:	70a2                	ld	ra,40(sp)
    800019ba:	7402                	ld	s0,32(sp)
    800019bc:	64e2                	ld	s1,24(sp)
    800019be:	6145                	addi	sp,sp,48
    800019c0:	8082                	ret
      panic("exec");
    800019c2:	00005517          	auipc	a0,0x5
    800019c6:	7c650513          	addi	a0,a0,1990 # 80007188 <etext+0x188>
    800019ca:	e4ffe0ef          	jal	80000818 <panic>

00000000800019ce <allocpid>:
{
    800019ce:	1101                	addi	sp,sp,-32
    800019d0:	ec06                	sd	ra,24(sp)
    800019d2:	e822                	sd	s0,16(sp)
    800019d4:	e426                	sd	s1,8(sp)
    800019d6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019d8:	00011517          	auipc	a0,0x11
    800019dc:	9d050513          	addi	a0,a0,-1584 # 800123a8 <pid_lock>
    800019e0:	a24ff0ef          	jal	80000c04 <acquire>
  pid = nextpid;
    800019e4:	00009797          	auipc	a5,0x9
    800019e8:	87078793          	addi	a5,a5,-1936 # 8000a254 <nextpid>
    800019ec:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019ee:	0014871b          	addiw	a4,s1,1
    800019f2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019f4:	00011517          	auipc	a0,0x11
    800019f8:	9b450513          	addi	a0,a0,-1612 # 800123a8 <pid_lock>
    800019fc:	a98ff0ef          	jal	80000c94 <release>
}
    80001a00:	8526                	mv	a0,s1
    80001a02:	60e2                	ld	ra,24(sp)
    80001a04:	6442                	ld	s0,16(sp)
    80001a06:	64a2                	ld	s1,8(sp)
    80001a08:	6105                	addi	sp,sp,32
    80001a0a:	8082                	ret

0000000080001a0c <proc_pagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a1a:	fc2ff0ef          	jal	800011dc <uvmcreate>
    80001a1e:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a20:	cd05                	beqz	a0,80001a58 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a22:	4729                	li	a4,10
    80001a24:	00004697          	auipc	a3,0x4
    80001a28:	5dc68693          	addi	a3,a3,1500 # 80006000 <_trampoline>
    80001a2c:	6605                	lui	a2,0x1
    80001a2e:	040005b7          	lui	a1,0x4000
    80001a32:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a34:	05b2                	slli	a1,a1,0xc
    80001a36:	dfeff0ef          	jal	80001034 <mappages>
    80001a3a:	02054663          	bltz	a0,80001a66 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a3e:	4719                	li	a4,6
    80001a40:	05893683          	ld	a3,88(s2)
    80001a44:	6605                	lui	a2,0x1
    80001a46:	020005b7          	lui	a1,0x2000
    80001a4a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a4c:	05b6                	slli	a1,a1,0xd
    80001a4e:	8526                	mv	a0,s1
    80001a50:	de4ff0ef          	jal	80001034 <mappages>
    80001a54:	00054f63          	bltz	a0,80001a72 <proc_pagetable+0x66>
}
    80001a58:	8526                	mv	a0,s1
    80001a5a:	60e2                	ld	ra,24(sp)
    80001a5c:	6442                	ld	s0,16(sp)
    80001a5e:	64a2                	ld	s1,8(sp)
    80001a60:	6902                	ld	s2,0(sp)
    80001a62:	6105                	addi	sp,sp,32
    80001a64:	8082                	ret
    uvmfree(pagetable, 0);
    80001a66:	4581                	li	a1,0
    80001a68:	8526                	mv	a0,s1
    80001a6a:	96dff0ef          	jal	800013d6 <uvmfree>
    return 0;
    80001a6e:	4481                	li	s1,0
    80001a70:	b7e5                	j	80001a58 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a72:	4681                	li	a3,0
    80001a74:	4605                	li	a2,1
    80001a76:	040005b7          	lui	a1,0x4000
    80001a7a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a7c:	05b2                	slli	a1,a1,0xc
    80001a7e:	8526                	mv	a0,s1
    80001a80:	f82ff0ef          	jal	80001202 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a84:	4581                	li	a1,0
    80001a86:	8526                	mv	a0,s1
    80001a88:	94fff0ef          	jal	800013d6 <uvmfree>
    return 0;
    80001a8c:	4481                	li	s1,0
    80001a8e:	b7e9                	j	80001a58 <proc_pagetable+0x4c>

0000000080001a90 <proc_freepagetable>:
{
    80001a90:	1101                	addi	sp,sp,-32
    80001a92:	ec06                	sd	ra,24(sp)
    80001a94:	e822                	sd	s0,16(sp)
    80001a96:	e426                	sd	s1,8(sp)
    80001a98:	e04a                	sd	s2,0(sp)
    80001a9a:	1000                	addi	s0,sp,32
    80001a9c:	84aa                	mv	s1,a0
    80001a9e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aa0:	4681                	li	a3,0
    80001aa2:	4605                	li	a2,1
    80001aa4:	040005b7          	lui	a1,0x4000
    80001aa8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aaa:	05b2                	slli	a1,a1,0xc
    80001aac:	f56ff0ef          	jal	80001202 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ab0:	4681                	li	a3,0
    80001ab2:	4605                	li	a2,1
    80001ab4:	020005b7          	lui	a1,0x2000
    80001ab8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aba:	05b6                	slli	a1,a1,0xd
    80001abc:	8526                	mv	a0,s1
    80001abe:	f44ff0ef          	jal	80001202 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ac2:	85ca                	mv	a1,s2
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	911ff0ef          	jal	800013d6 <uvmfree>
}
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret

0000000080001ad6 <freeproc>:
{
    80001ad6:	1101                	addi	sp,sp,-32
    80001ad8:	ec06                	sd	ra,24(sp)
    80001ada:	e822                	sd	s0,16(sp)
    80001adc:	e426                	sd	s1,8(sp)
    80001ade:	1000                	addi	s0,sp,32
    80001ae0:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ae2:	6d28                	ld	a0,88(a0)
    80001ae4:	c119                	beqz	a0,80001aea <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001ae6:	f53fe0ef          	jal	80000a38 <kfree>
  p->trapframe = 0;
    80001aea:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001aee:	68a8                	ld	a0,80(s1)
    80001af0:	c501                	beqz	a0,80001af8 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001af2:	64ac                	ld	a1,72(s1)
    80001af4:	f9dff0ef          	jal	80001a90 <proc_freepagetable>
  p->pagetable = 0;
    80001af8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001afc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b00:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b04:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b08:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b0c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b10:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b14:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b18:	0004ac23          	sw	zero,24(s1)
}
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret

0000000080001b26 <allocproc>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b32:	00011497          	auipc	s1,0x11
    80001b36:	ca648493          	addi	s1,s1,-858 # 800127d8 <proc>
    80001b3a:	00016917          	auipc	s2,0x16
    80001b3e:	69e90913          	addi	s2,s2,1694 # 800181d8 <tickslock>
    acquire(&p->lock);
    80001b42:	8526                	mv	a0,s1
    80001b44:	8c0ff0ef          	jal	80000c04 <acquire>
    if (p->state == UNUSED) {
    80001b48:	4c9c                	lw	a5,24(s1)
    80001b4a:	cb91                	beqz	a5,80001b5e <allocproc+0x38>
      release(&p->lock);
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	946ff0ef          	jal	80000c94 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b52:	16848493          	addi	s1,s1,360
    80001b56:	ff2496e3          	bne	s1,s2,80001b42 <allocproc+0x1c>
  return 0;
    80001b5a:	4481                	li	s1,0
    80001b5c:	a089                	j	80001b9e <allocproc+0x78>
  p->pid = allocpid();
    80001b5e:	e71ff0ef          	jal	800019ce <allocpid>
    80001b62:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b64:	4785                	li	a5,1
    80001b66:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b68:	fb9fe0ef          	jal	80000b20 <kalloc>
    80001b6c:	892a                	mv	s2,a0
    80001b6e:	eca8                	sd	a0,88(s1)
    80001b70:	cd15                	beqz	a0,80001bac <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b72:	8526                	mv	a0,s1
    80001b74:	e99ff0ef          	jal	80001a0c <proc_pagetable>
    80001b78:	892a                	mv	s2,a0
    80001b7a:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b7c:	c121                	beqz	a0,80001bbc <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b7e:	07000613          	li	a2,112
    80001b82:	4581                	li	a1,0
    80001b84:	06048513          	addi	a0,s1,96
    80001b88:	944ff0ef          	jal	80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001b8c:	00000797          	auipc	a5,0x0
    80001b90:	da878793          	addi	a5,a5,-600 # 80001934 <forkret>
    80001b94:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b96:	60bc                	ld	a5,64(s1)
    80001b98:	6705                	lui	a4,0x1
    80001b9a:	97ba                	add	a5,a5,a4
    80001b9c:	f4bc                	sd	a5,104(s1)
}
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	60e2                	ld	ra,24(sp)
    80001ba2:	6442                	ld	s0,16(sp)
    80001ba4:	64a2                	ld	s1,8(sp)
    80001ba6:	6902                	ld	s2,0(sp)
    80001ba8:	6105                	addi	sp,sp,32
    80001baa:	8082                	ret
    freeproc(p);
    80001bac:	8526                	mv	a0,s1
    80001bae:	f29ff0ef          	jal	80001ad6 <freeproc>
    release(&p->lock);
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	8e0ff0ef          	jal	80000c94 <release>
    return 0;
    80001bb8:	84ca                	mv	s1,s2
    80001bba:	b7d5                	j	80001b9e <allocproc+0x78>
    freeproc(p);
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	f19ff0ef          	jal	80001ad6 <freeproc>
    release(&p->lock);
    80001bc2:	8526                	mv	a0,s1
    80001bc4:	8d0ff0ef          	jal	80000c94 <release>
    return 0;
    80001bc8:	84ca                	mv	s1,s2
    80001bca:	bfd1                	j	80001b9e <allocproc+0x78>

0000000080001bcc <userinit>:
{
    80001bcc:	1101                	addi	sp,sp,-32
    80001bce:	ec06                	sd	ra,24(sp)
    80001bd0:	e822                	sd	s0,16(sp)
    80001bd2:	e426                	sd	s1,8(sp)
    80001bd4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bd6:	f51ff0ef          	jal	80001b26 <allocproc>
    80001bda:	84aa                	mv	s1,a0
  initproc = p;
    80001bdc:	00008797          	auipc	a5,0x8
    80001be0:	6ca7b223          	sd	a0,1732(a5) # 8000a2a0 <initproc>
  p->cwd = namei("/");
    80001be4:	00005517          	auipc	a0,0x5
    80001be8:	5ac50513          	addi	a0,a0,1452 # 80007190 <etext+0x190>
    80001bec:	651010ef          	jal	80003a3c <namei>
    80001bf0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bf4:	478d                	li	a5,3
    80001bf6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	89aff0ef          	jal	80000c94 <release>
}
    80001bfe:	60e2                	ld	ra,24(sp)
    80001c00:	6442                	ld	s0,16(sp)
    80001c02:	64a2                	ld	s1,8(sp)
    80001c04:	6105                	addi	sp,sp,32
    80001c06:	8082                	ret

0000000080001c08 <growproc>:
{
    80001c08:	1101                	addi	sp,sp,-32
    80001c0a:	ec06                	sd	ra,24(sp)
    80001c0c:	e822                	sd	s0,16(sp)
    80001c0e:	e426                	sd	s1,8(sp)
    80001c10:	e04a                	sd	s2,0(sp)
    80001c12:	1000                	addi	s0,sp,32
    80001c14:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c16:	cedff0ef          	jal	80001902 <myproc>
    80001c1a:	892a                	mv	s2,a0
  sz = p->sz;
    80001c1c:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c1e:	02905963          	blez	s1,80001c50 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c22:	00b48633          	add	a2,s1,a1
    80001c26:	020007b7          	lui	a5,0x2000
    80001c2a:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c2c:	07b6                	slli	a5,a5,0xd
    80001c2e:	02c7ea63          	bltu	a5,a2,80001c62 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c32:	4691                	li	a3,4
    80001c34:	6928                	ld	a0,80(a0)
    80001c36:	e9aff0ef          	jal	800012d0 <uvmalloc>
    80001c3a:	85aa                	mv	a1,a0
    80001c3c:	c50d                	beqz	a0,80001c66 <growproc+0x5e>
  p->sz = sz;
    80001c3e:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c42:	4501                	li	a0,0
}
    80001c44:	60e2                	ld	ra,24(sp)
    80001c46:	6442                	ld	s0,16(sp)
    80001c48:	64a2                	ld	s1,8(sp)
    80001c4a:	6902                	ld	s2,0(sp)
    80001c4c:	6105                	addi	sp,sp,32
    80001c4e:	8082                	ret
  } else if (n < 0) {
    80001c50:	fe04d7e3          	bgez	s1,80001c3e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c54:	00b48633          	add	a2,s1,a1
    80001c58:	6928                	ld	a0,80(a0)
    80001c5a:	e32ff0ef          	jal	8000128c <uvmdealloc>
    80001c5e:	85aa                	mv	a1,a0
    80001c60:	bff9                	j	80001c3e <growproc+0x36>
      return -1;
    80001c62:	557d                	li	a0,-1
    80001c64:	b7c5                	j	80001c44 <growproc+0x3c>
      return -1;
    80001c66:	557d                	li	a0,-1
    80001c68:	bff1                	j	80001c44 <growproc+0x3c>

0000000080001c6a <kfork>:
{
    80001c6a:	7139                	addi	sp,sp,-64
    80001c6c:	fc06                	sd	ra,56(sp)
    80001c6e:	f822                	sd	s0,48(sp)
    80001c70:	f426                	sd	s1,40(sp)
    80001c72:	e456                	sd	s5,8(sp)
    80001c74:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c76:	c8dff0ef          	jal	80001902 <myproc>
    80001c7a:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c7c:	eabff0ef          	jal	80001b26 <allocproc>
    80001c80:	0e050a63          	beqz	a0,80001d74 <kfork+0x10a>
    80001c84:	e852                	sd	s4,16(sp)
    80001c86:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c88:	048ab603          	ld	a2,72(s5)
    80001c8c:	692c                	ld	a1,80(a0)
    80001c8e:	050ab503          	ld	a0,80(s5)
    80001c92:	f76ff0ef          	jal	80001408 <uvmcopy>
    80001c96:	04054863          	bltz	a0,80001ce6 <kfork+0x7c>
    80001c9a:	f04a                	sd	s2,32(sp)
    80001c9c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c9e:	048ab783          	ld	a5,72(s5)
    80001ca2:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ca6:	058ab683          	ld	a3,88(s5)
    80001caa:	87b6                	mv	a5,a3
    80001cac:	058a3703          	ld	a4,88(s4)
    80001cb0:	12068693          	addi	a3,a3,288
    80001cb4:	6388                	ld	a0,0(a5)
    80001cb6:	678c                	ld	a1,8(a5)
    80001cb8:	6b90                	ld	a2,16(a5)
    80001cba:	e308                	sd	a0,0(a4)
    80001cbc:	e70c                	sd	a1,8(a4)
    80001cbe:	eb10                	sd	a2,16(a4)
    80001cc0:	6f90                	ld	a2,24(a5)
    80001cc2:	ef10                	sd	a2,24(a4)
    80001cc4:	02078793          	addi	a5,a5,32
    80001cc8:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001ccc:	fed794e3          	bne	a5,a3,80001cb4 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cd0:	058a3783          	ld	a5,88(s4)
    80001cd4:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cd8:	0d0a8493          	addi	s1,s5,208
    80001cdc:	0d0a0913          	addi	s2,s4,208
    80001ce0:	150a8993          	addi	s3,s5,336
    80001ce4:	a831                	j	80001d00 <kfork+0x96>
    freeproc(np);
    80001ce6:	8552                	mv	a0,s4
    80001ce8:	defff0ef          	jal	80001ad6 <freeproc>
    release(&np->lock);
    80001cec:	8552                	mv	a0,s4
    80001cee:	fa7fe0ef          	jal	80000c94 <release>
    return -1;
    80001cf2:	54fd                	li	s1,-1
    80001cf4:	6a42                	ld	s4,16(sp)
    80001cf6:	a885                	j	80001d66 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001cf8:	04a1                	addi	s1,s1,8
    80001cfa:	0921                	addi	s2,s2,8
    80001cfc:	01348963          	beq	s1,s3,80001d0e <kfork+0xa4>
    if (p->ofile[i])
    80001d00:	6088                	ld	a0,0(s1)
    80001d02:	d97d                	beqz	a0,80001cf8 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d04:	352020ef          	jal	80004056 <filedup>
    80001d08:	00a93023          	sd	a0,0(s2)
    80001d0c:	b7f5                	j	80001cf8 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d0e:	150ab503          	ld	a0,336(s5)
    80001d12:	4c6010ef          	jal	800031d8 <idup>
    80001d16:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d1a:	4641                	li	a2,16
    80001d1c:	158a8593          	addi	a1,s5,344
    80001d20:	158a0513          	addi	a0,s4,344
    80001d24:	8fcff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001d28:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d2c:	8552                	mv	a0,s4
    80001d2e:	f67fe0ef          	jal	80000c94 <release>
  acquire(&wait_lock);
    80001d32:	00010517          	auipc	a0,0x10
    80001d36:	68e50513          	addi	a0,a0,1678 # 800123c0 <wait_lock>
    80001d3a:	ecbfe0ef          	jal	80000c04 <acquire>
  np->parent = p;
    80001d3e:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d42:	00010517          	auipc	a0,0x10
    80001d46:	67e50513          	addi	a0,a0,1662 # 800123c0 <wait_lock>
    80001d4a:	f4bfe0ef          	jal	80000c94 <release>
  acquire(&np->lock);
    80001d4e:	8552                	mv	a0,s4
    80001d50:	eb5fe0ef          	jal	80000c04 <acquire>
  np->state = RUNNABLE;
    80001d54:	478d                	li	a5,3
    80001d56:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d5a:	8552                	mv	a0,s4
    80001d5c:	f39fe0ef          	jal	80000c94 <release>
  return pid;
    80001d60:	7902                	ld	s2,32(sp)
    80001d62:	69e2                	ld	s3,24(sp)
    80001d64:	6a42                	ld	s4,16(sp)
}
    80001d66:	8526                	mv	a0,s1
    80001d68:	70e2                	ld	ra,56(sp)
    80001d6a:	7442                	ld	s0,48(sp)
    80001d6c:	74a2                	ld	s1,40(sp)
    80001d6e:	6aa2                	ld	s5,8(sp)
    80001d70:	6121                	addi	sp,sp,64
    80001d72:	8082                	ret
    return -1;
    80001d74:	54fd                	li	s1,-1
    80001d76:	bfc5                	j	80001d66 <kfork+0xfc>

0000000080001d78 <scheduler>:
{
    80001d78:	715d                	addi	sp,sp,-80
    80001d7a:	e486                	sd	ra,72(sp)
    80001d7c:	e0a2                	sd	s0,64(sp)
    80001d7e:	fc26                	sd	s1,56(sp)
    80001d80:	f84a                	sd	s2,48(sp)
    80001d82:	f44e                	sd	s3,40(sp)
    80001d84:	f052                	sd	s4,32(sp)
    80001d86:	ec56                	sd	s5,24(sp)
    80001d88:	e85a                	sd	s6,16(sp)
    80001d8a:	e45e                	sd	s7,8(sp)
    80001d8c:	e062                	sd	s8,0(sp)
    80001d8e:	0880                	addi	s0,sp,80
    80001d90:	8792                	mv	a5,tp
  int id = r_tp();
    80001d92:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d94:	00779b13          	slli	s6,a5,0x7
    80001d98:	00010717          	auipc	a4,0x10
    80001d9c:	61070713          	addi	a4,a4,1552 # 800123a8 <pid_lock>
    80001da0:	975a                	add	a4,a4,s6
    80001da2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001da6:	00010717          	auipc	a4,0x10
    80001daa:	63a70713          	addi	a4,a4,1594 # 800123e0 <cpus+0x8>
    80001dae:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001db0:	4c11                	li	s8,4
        c->proc = p;
    80001db2:	079e                	slli	a5,a5,0x7
    80001db4:	00010a17          	auipc	s4,0x10
    80001db8:	5f4a0a13          	addi	s4,s4,1524 # 800123a8 <pid_lock>
    80001dbc:	9a3e                	add	s4,s4,a5
        found = 1;
    80001dbe:	4b85                	li	s7,1
    80001dc0:	a83d                	j	80001dfe <scheduler+0x86>
      release(&p->lock);
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	ed1fe0ef          	jal	80000c94 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dc8:	16848493          	addi	s1,s1,360
    80001dcc:	03248563          	beq	s1,s2,80001df6 <scheduler+0x7e>
      acquire(&p->lock);
    80001dd0:	8526                	mv	a0,s1
    80001dd2:	e33fe0ef          	jal	80000c04 <acquire>
      if(p->state == RUNNABLE) {
    80001dd6:	4c9c                	lw	a5,24(s1)
    80001dd8:	ff3795e3          	bne	a5,s3,80001dc2 <scheduler+0x4a>
        p->state = RUNNING;
    80001ddc:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001de0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001de4:	06048593          	addi	a1,s1,96
    80001de8:	855a                	mv	a0,s6
    80001dea:	5b0000ef          	jal	8000239a <swtch>
        c->proc = 0;
    80001dee:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001df2:	8ade                	mv	s5,s7
    80001df4:	b7f9                	j	80001dc2 <scheduler+0x4a>
    if(found == 0) {
    80001df6:	000a9463          	bnez	s5,80001dfe <scheduler+0x86>
      asm volatile("wfi");
    80001dfa:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001dfe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e02:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001e06:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e0a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e0c:	00011497          	auipc	s1,0x11
    80001e10:	9cc48493          	addi	s1,s1,-1588 # 800127d8 <proc>
      if(p->state == RUNNABLE) {
    80001e14:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e16:	00016917          	auipc	s2,0x16
    80001e1a:	3c290913          	addi	s2,s2,962 # 800181d8 <tickslock>
    80001e1e:	bf4d                	j	80001dd0 <scheduler+0x58>

0000000080001e20 <sched>:
{
    80001e20:	7179                	addi	sp,sp,-48
    80001e22:	f406                	sd	ra,40(sp)
    80001e24:	f022                	sd	s0,32(sp)
    80001e26:	ec26                	sd	s1,24(sp)
    80001e28:	e84a                	sd	s2,16(sp)
    80001e2a:	e44e                	sd	s3,8(sp)
    80001e2c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e2e:	ad5ff0ef          	jal	80001902 <myproc>
    80001e32:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e34:	d61fe0ef          	jal	80000b94 <holding>
    80001e38:	c935                	beqz	a0,80001eac <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e3a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e3c:	2781                	sext.w	a5,a5
    80001e3e:	079e                	slli	a5,a5,0x7
    80001e40:	00010717          	auipc	a4,0x10
    80001e44:	56870713          	addi	a4,a4,1384 # 800123a8 <pid_lock>
    80001e48:	97ba                	add	a5,a5,a4
    80001e4a:	0a87a703          	lw	a4,168(a5)
    80001e4e:	4785                	li	a5,1
    80001e50:	06f71463          	bne	a4,a5,80001eb8 <sched+0x98>
  if (p->state == RUNNING)
    80001e54:	4c98                	lw	a4,24(s1)
    80001e56:	4791                	li	a5,4
    80001e58:	06f70663          	beq	a4,a5,80001ec4 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e5c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e60:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e62:	e7bd                	bnez	a5,80001ed0 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e64:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e66:	00010917          	auipc	s2,0x10
    80001e6a:	54290913          	addi	s2,s2,1346 # 800123a8 <pid_lock>
    80001e6e:	2781                	sext.w	a5,a5
    80001e70:	079e                	slli	a5,a5,0x7
    80001e72:	97ca                	add	a5,a5,s2
    80001e74:	0ac7a983          	lw	s3,172(a5)
    80001e78:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e7a:	2781                	sext.w	a5,a5
    80001e7c:	079e                	slli	a5,a5,0x7
    80001e7e:	07a1                	addi	a5,a5,8
    80001e80:	00010597          	auipc	a1,0x10
    80001e84:	55858593          	addi	a1,a1,1368 # 800123d8 <cpus>
    80001e88:	95be                	add	a1,a1,a5
    80001e8a:	06048513          	addi	a0,s1,96
    80001e8e:	50c000ef          	jal	8000239a <swtch>
    80001e92:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e94:	2781                	sext.w	a5,a5
    80001e96:	079e                	slli	a5,a5,0x7
    80001e98:	993e                	add	s2,s2,a5
    80001e9a:	0b392623          	sw	s3,172(s2)
}
    80001e9e:	70a2                	ld	ra,40(sp)
    80001ea0:	7402                	ld	s0,32(sp)
    80001ea2:	64e2                	ld	s1,24(sp)
    80001ea4:	6942                	ld	s2,16(sp)
    80001ea6:	69a2                	ld	s3,8(sp)
    80001ea8:	6145                	addi	sp,sp,48
    80001eaa:	8082                	ret
    panic("sched p->lock");
    80001eac:	00005517          	auipc	a0,0x5
    80001eb0:	2ec50513          	addi	a0,a0,748 # 80007198 <etext+0x198>
    80001eb4:	965fe0ef          	jal	80000818 <panic>
    panic("sched locks");
    80001eb8:	00005517          	auipc	a0,0x5
    80001ebc:	2f050513          	addi	a0,a0,752 # 800071a8 <etext+0x1a8>
    80001ec0:	959fe0ef          	jal	80000818 <panic>
    panic("sched RUNNING");
    80001ec4:	00005517          	auipc	a0,0x5
    80001ec8:	2f450513          	addi	a0,a0,756 # 800071b8 <etext+0x1b8>
    80001ecc:	94dfe0ef          	jal	80000818 <panic>
    panic("sched interruptible");
    80001ed0:	00005517          	auipc	a0,0x5
    80001ed4:	2f850513          	addi	a0,a0,760 # 800071c8 <etext+0x1c8>
    80001ed8:	941fe0ef          	jal	80000818 <panic>

0000000080001edc <yield>:
{
    80001edc:	1101                	addi	sp,sp,-32
    80001ede:	ec06                	sd	ra,24(sp)
    80001ee0:	e822                	sd	s0,16(sp)
    80001ee2:	e426                	sd	s1,8(sp)
    80001ee4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ee6:	a1dff0ef          	jal	80001902 <myproc>
    80001eea:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001eec:	d19fe0ef          	jal	80000c04 <acquire>
  p->state = RUNNABLE;
    80001ef0:	478d                	li	a5,3
    80001ef2:	cc9c                	sw	a5,24(s1)
  sched();
    80001ef4:	f2dff0ef          	jal	80001e20 <sched>
  release(&p->lock);
    80001ef8:	8526                	mv	a0,s1
    80001efa:	d9bfe0ef          	jal	80000c94 <release>
}
    80001efe:	60e2                	ld	ra,24(sp)
    80001f00:	6442                	ld	s0,16(sp)
    80001f02:	64a2                	ld	s1,8(sp)
    80001f04:	6105                	addi	sp,sp,32
    80001f06:	8082                	ret

0000000080001f08 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f08:	7179                	addi	sp,sp,-48
    80001f0a:	f406                	sd	ra,40(sp)
    80001f0c:	f022                	sd	s0,32(sp)
    80001f0e:	ec26                	sd	s1,24(sp)
    80001f10:	e84a                	sd	s2,16(sp)
    80001f12:	e44e                	sd	s3,8(sp)
    80001f14:	1800                	addi	s0,sp,48
    80001f16:	89aa                	mv	s3,a0
    80001f18:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f1a:	9e9ff0ef          	jal	80001902 <myproc>
    80001f1e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); //DOC: sleeplock1
    80001f20:	ce5fe0ef          	jal	80000c04 <acquire>
  release(lk);
    80001f24:	854a                	mv	a0,s2
    80001f26:	d6ffe0ef          	jal	80000c94 <release>

  // Go to sleep.
  p->chan = chan;
    80001f2a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f2e:	4789                	li	a5,2
    80001f30:	cc9c                	sw	a5,24(s1)

  sched();
    80001f32:	eefff0ef          	jal	80001e20 <sched>

  // Tidy up.
  p->chan = 0;
    80001f36:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	d59fe0ef          	jal	80000c94 <release>
  acquire(lk);
    80001f40:	854a                	mv	a0,s2
    80001f42:	cc3fe0ef          	jal	80000c04 <acquire>
}
    80001f46:	70a2                	ld	ra,40(sp)
    80001f48:	7402                	ld	s0,32(sp)
    80001f4a:	64e2                	ld	s1,24(sp)
    80001f4c:	6942                	ld	s2,16(sp)
    80001f4e:	69a2                	ld	s3,8(sp)
    80001f50:	6145                	addi	sp,sp,48
    80001f52:	8082                	ret

0000000080001f54 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f54:	7139                	addi	sp,sp,-64
    80001f56:	fc06                	sd	ra,56(sp)
    80001f58:	f822                	sd	s0,48(sp)
    80001f5a:	f426                	sd	s1,40(sp)
    80001f5c:	f04a                	sd	s2,32(sp)
    80001f5e:	ec4e                	sd	s3,24(sp)
    80001f60:	e852                	sd	s4,16(sp)
    80001f62:	e456                	sd	s5,8(sp)
    80001f64:	0080                	addi	s0,sp,64
    80001f66:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001f68:	00011497          	auipc	s1,0x11
    80001f6c:	87048493          	addi	s1,s1,-1936 # 800127d8 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001f70:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f72:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f74:	00016917          	auipc	s2,0x16
    80001f78:	26490913          	addi	s2,s2,612 # 800181d8 <tickslock>
    80001f7c:	a801                	j	80001f8c <wakeup+0x38>
      }
      release(&p->lock);
    80001f7e:	8526                	mv	a0,s1
    80001f80:	d15fe0ef          	jal	80000c94 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f84:	16848493          	addi	s1,s1,360
    80001f88:	03248263          	beq	s1,s2,80001fac <wakeup+0x58>
    if (p != myproc()) {
    80001f8c:	977ff0ef          	jal	80001902 <myproc>
    80001f90:	fe950ae3          	beq	a0,s1,80001f84 <wakeup+0x30>
      acquire(&p->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	c6ffe0ef          	jal	80000c04 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80001f9a:	4c9c                	lw	a5,24(s1)
    80001f9c:	ff3791e3          	bne	a5,s3,80001f7e <wakeup+0x2a>
    80001fa0:	709c                	ld	a5,32(s1)
    80001fa2:	fd479ee3          	bne	a5,s4,80001f7e <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fa6:	0154ac23          	sw	s5,24(s1)
    80001faa:	bfd1                	j	80001f7e <wakeup+0x2a>
    }
  }
}
    80001fac:	70e2                	ld	ra,56(sp)
    80001fae:	7442                	ld	s0,48(sp)
    80001fb0:	74a2                	ld	s1,40(sp)
    80001fb2:	7902                	ld	s2,32(sp)
    80001fb4:	69e2                	ld	s3,24(sp)
    80001fb6:	6a42                	ld	s4,16(sp)
    80001fb8:	6aa2                	ld	s5,8(sp)
    80001fba:	6121                	addi	sp,sp,64
    80001fbc:	8082                	ret

0000000080001fbe <reparent>:
{
    80001fbe:	7179                	addi	sp,sp,-48
    80001fc0:	f406                	sd	ra,40(sp)
    80001fc2:	f022                	sd	s0,32(sp)
    80001fc4:	ec26                	sd	s1,24(sp)
    80001fc6:	e84a                	sd	s2,16(sp)
    80001fc8:	e44e                	sd	s3,8(sp)
    80001fca:	e052                	sd	s4,0(sp)
    80001fcc:	1800                	addi	s0,sp,48
    80001fce:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001fd0:	00011497          	auipc	s1,0x11
    80001fd4:	80848493          	addi	s1,s1,-2040 # 800127d8 <proc>
      pp->parent = initproc;
    80001fd8:	00008a17          	auipc	s4,0x8
    80001fdc:	2c8a0a13          	addi	s4,s4,712 # 8000a2a0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001fe0:	00016997          	auipc	s3,0x16
    80001fe4:	1f898993          	addi	s3,s3,504 # 800181d8 <tickslock>
    80001fe8:	a029                	j	80001ff2 <reparent+0x34>
    80001fea:	16848493          	addi	s1,s1,360
    80001fee:	01348b63          	beq	s1,s3,80002004 <reparent+0x46>
    if (pp->parent == p) {
    80001ff2:	7c9c                	ld	a5,56(s1)
    80001ff4:	ff279be3          	bne	a5,s2,80001fea <reparent+0x2c>
      pp->parent = initproc;
    80001ff8:	000a3503          	ld	a0,0(s4)
    80001ffc:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001ffe:	f57ff0ef          	jal	80001f54 <wakeup>
    80002002:	b7e5                	j	80001fea <reparent+0x2c>
}
    80002004:	70a2                	ld	ra,40(sp)
    80002006:	7402                	ld	s0,32(sp)
    80002008:	64e2                	ld	s1,24(sp)
    8000200a:	6942                	ld	s2,16(sp)
    8000200c:	69a2                	ld	s3,8(sp)
    8000200e:	6a02                	ld	s4,0(sp)
    80002010:	6145                	addi	sp,sp,48
    80002012:	8082                	ret

0000000080002014 <kexit>:
{
    80002014:	7179                	addi	sp,sp,-48
    80002016:	f406                	sd	ra,40(sp)
    80002018:	f022                	sd	s0,32(sp)
    8000201a:	ec26                	sd	s1,24(sp)
    8000201c:	e84a                	sd	s2,16(sp)
    8000201e:	e44e                	sd	s3,8(sp)
    80002020:	e052                	sd	s4,0(sp)
    80002022:	1800                	addi	s0,sp,48
    80002024:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002026:	8ddff0ef          	jal	80001902 <myproc>
    8000202a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000202c:	00008797          	auipc	a5,0x8
    80002030:	2747b783          	ld	a5,628(a5) # 8000a2a0 <initproc>
    80002034:	0d050493          	addi	s1,a0,208
    80002038:	15050913          	addi	s2,a0,336
    8000203c:	00a79b63          	bne	a5,a0,80002052 <kexit+0x3e>
    panic("init exiting");
    80002040:	00005517          	auipc	a0,0x5
    80002044:	1a050513          	addi	a0,a0,416 # 800071e0 <etext+0x1e0>
    80002048:	fd0fe0ef          	jal	80000818 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    8000204c:	04a1                	addi	s1,s1,8
    8000204e:	01248963          	beq	s1,s2,80002060 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002052:	6088                	ld	a0,0(s1)
    80002054:	dd65                	beqz	a0,8000204c <kexit+0x38>
      fileclose(f);
    80002056:	046020ef          	jal	8000409c <fileclose>
      p->ofile[fd] = 0;
    8000205a:	0004b023          	sd	zero,0(s1)
    8000205e:	b7fd                	j	8000204c <kexit+0x38>
  begin_op();
    80002060:	3bb010ef          	jal	80003c1a <begin_op>
  iput(p->cwd);
    80002064:	1509b503          	ld	a0,336(s3)
    80002068:	328010ef          	jal	80003390 <iput>
  end_op();
    8000206c:	41f010ef          	jal	80003c8a <end_op>
  p->cwd = 0;
    80002070:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002074:	00010517          	auipc	a0,0x10
    80002078:	34c50513          	addi	a0,a0,844 # 800123c0 <wait_lock>
    8000207c:	b89fe0ef          	jal	80000c04 <acquire>
  reparent(p);
    80002080:	854e                	mv	a0,s3
    80002082:	f3dff0ef          	jal	80001fbe <reparent>
  wakeup(p->parent);
    80002086:	0389b503          	ld	a0,56(s3)
    8000208a:	ecbff0ef          	jal	80001f54 <wakeup>
  acquire(&p->lock);
    8000208e:	854e                	mv	a0,s3
    80002090:	b75fe0ef          	jal	80000c04 <acquire>
  p->xstate = status;
    80002094:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002098:	4795                	li	a5,5
    8000209a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000209e:	00010517          	auipc	a0,0x10
    800020a2:	32250513          	addi	a0,a0,802 # 800123c0 <wait_lock>
    800020a6:	beffe0ef          	jal	80000c94 <release>
  sched();
    800020aa:	d77ff0ef          	jal	80001e20 <sched>
  panic("zombie exit");
    800020ae:	00005517          	auipc	a0,0x5
    800020b2:	14250513          	addi	a0,a0,322 # 800071f0 <etext+0x1f0>
    800020b6:	f62fe0ef          	jal	80000818 <panic>

00000000800020ba <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020ba:	7179                	addi	sp,sp,-48
    800020bc:	f406                	sd	ra,40(sp)
    800020be:	f022                	sd	s0,32(sp)
    800020c0:	ec26                	sd	s1,24(sp)
    800020c2:	e84a                	sd	s2,16(sp)
    800020c4:	e44e                	sd	s3,8(sp)
    800020c6:	1800                	addi	s0,sp,48
    800020c8:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800020ca:	00010497          	auipc	s1,0x10
    800020ce:	70e48493          	addi	s1,s1,1806 # 800127d8 <proc>
    800020d2:	00016997          	auipc	s3,0x16
    800020d6:	10698993          	addi	s3,s3,262 # 800181d8 <tickslock>
    acquire(&p->lock);
    800020da:	8526                	mv	a0,s1
    800020dc:	b29fe0ef          	jal	80000c04 <acquire>
    if (p->pid == pid) {
    800020e0:	589c                	lw	a5,48(s1)
    800020e2:	01278b63          	beq	a5,s2,800020f8 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	badfe0ef          	jal	80000c94 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020ec:	16848493          	addi	s1,s1,360
    800020f0:	ff3495e3          	bne	s1,s3,800020da <kkill+0x20>
  }
  return -1;
    800020f4:	557d                	li	a0,-1
    800020f6:	a819                	j	8000210c <kkill+0x52>
      p->killed = 1;
    800020f8:	4785                	li	a5,1
    800020fa:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800020fc:	4c98                	lw	a4,24(s1)
    800020fe:	4789                	li	a5,2
    80002100:	00f70d63          	beq	a4,a5,8000211a <kkill+0x60>
      release(&p->lock);
    80002104:	8526                	mv	a0,s1
    80002106:	b8ffe0ef          	jal	80000c94 <release>
      return 0;
    8000210a:	4501                	li	a0,0
}
    8000210c:	70a2                	ld	ra,40(sp)
    8000210e:	7402                	ld	s0,32(sp)
    80002110:	64e2                	ld	s1,24(sp)
    80002112:	6942                	ld	s2,16(sp)
    80002114:	69a2                	ld	s3,8(sp)
    80002116:	6145                	addi	sp,sp,48
    80002118:	8082                	ret
        p->state = RUNNABLE;
    8000211a:	478d                	li	a5,3
    8000211c:	cc9c                	sw	a5,24(s1)
    8000211e:	b7dd                	j	80002104 <kkill+0x4a>

0000000080002120 <setkilled>:

void
setkilled(struct proc *p)
{
    80002120:	1101                	addi	sp,sp,-32
    80002122:	ec06                	sd	ra,24(sp)
    80002124:	e822                	sd	s0,16(sp)
    80002126:	e426                	sd	s1,8(sp)
    80002128:	1000                	addi	s0,sp,32
    8000212a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000212c:	ad9fe0ef          	jal	80000c04 <acquire>
  p->killed = 1;
    80002130:	4785                	li	a5,1
    80002132:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002134:	8526                	mv	a0,s1
    80002136:	b5ffe0ef          	jal	80000c94 <release>
}
    8000213a:	60e2                	ld	ra,24(sp)
    8000213c:	6442                	ld	s0,16(sp)
    8000213e:	64a2                	ld	s1,8(sp)
    80002140:	6105                	addi	sp,sp,32
    80002142:	8082                	ret

0000000080002144 <killed>:

int
killed(struct proc *p)
{
    80002144:	1101                	addi	sp,sp,-32
    80002146:	ec06                	sd	ra,24(sp)
    80002148:	e822                	sd	s0,16(sp)
    8000214a:	e426                	sd	s1,8(sp)
    8000214c:	e04a                	sd	s2,0(sp)
    8000214e:	1000                	addi	s0,sp,32
    80002150:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002152:	ab3fe0ef          	jal	80000c04 <acquire>
  k = p->killed;
    80002156:	549c                	lw	a5,40(s1)
    80002158:	893e                	mv	s2,a5
  release(&p->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	b39fe0ef          	jal	80000c94 <release>
  return k;
}
    80002160:	854a                	mv	a0,s2
    80002162:	60e2                	ld	ra,24(sp)
    80002164:	6442                	ld	s0,16(sp)
    80002166:	64a2                	ld	s1,8(sp)
    80002168:	6902                	ld	s2,0(sp)
    8000216a:	6105                	addi	sp,sp,32
    8000216c:	8082                	ret

000000008000216e <kwait>:
{
    8000216e:	715d                	addi	sp,sp,-80
    80002170:	e486                	sd	ra,72(sp)
    80002172:	e0a2                	sd	s0,64(sp)
    80002174:	fc26                	sd	s1,56(sp)
    80002176:	f84a                	sd	s2,48(sp)
    80002178:	f44e                	sd	s3,40(sp)
    8000217a:	f052                	sd	s4,32(sp)
    8000217c:	ec56                	sd	s5,24(sp)
    8000217e:	e85a                	sd	s6,16(sp)
    80002180:	e45e                	sd	s7,8(sp)
    80002182:	0880                	addi	s0,sp,80
    80002184:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002186:	f7cff0ef          	jal	80001902 <myproc>
    8000218a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000218c:	00010517          	auipc	a0,0x10
    80002190:	23450513          	addi	a0,a0,564 # 800123c0 <wait_lock>
    80002194:	a71fe0ef          	jal	80000c04 <acquire>
        if (pp->state == ZOMBIE) {
    80002198:	4a15                	li	s4,5
        havekids = 1;
    8000219a:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000219c:	00016997          	auipc	s3,0x16
    800021a0:	03c98993          	addi	s3,s3,60 # 800181d8 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    800021a4:	00010b17          	auipc	s6,0x10
    800021a8:	21cb0b13          	addi	s6,s6,540 # 800123c0 <wait_lock>
    800021ac:	a869                	j	80002246 <kwait+0xd8>
          pid = pp->pid;
    800021ae:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021b2:	000b8c63          	beqz	s7,800021ca <kwait+0x5c>
    800021b6:	4691                	li	a3,4
    800021b8:	02c48613          	addi	a2,s1,44
    800021bc:	85de                	mv	a1,s7
    800021be:	05093503          	ld	a0,80(s2)
    800021c2:	c66ff0ef          	jal	80001628 <copyout>
    800021c6:	02054a63          	bltz	a0,800021fa <kwait+0x8c>
          freeproc(pp);
    800021ca:	8526                	mv	a0,s1
    800021cc:	90bff0ef          	jal	80001ad6 <freeproc>
          release(&pp->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	ac3fe0ef          	jal	80000c94 <release>
          release(&wait_lock);
    800021d6:	00010517          	auipc	a0,0x10
    800021da:	1ea50513          	addi	a0,a0,490 # 800123c0 <wait_lock>
    800021de:	ab7fe0ef          	jal	80000c94 <release>
}
    800021e2:	854e                	mv	a0,s3
    800021e4:	60a6                	ld	ra,72(sp)
    800021e6:	6406                	ld	s0,64(sp)
    800021e8:	74e2                	ld	s1,56(sp)
    800021ea:	7942                	ld	s2,48(sp)
    800021ec:	79a2                	ld	s3,40(sp)
    800021ee:	7a02                	ld	s4,32(sp)
    800021f0:	6ae2                	ld	s5,24(sp)
    800021f2:	6b42                	ld	s6,16(sp)
    800021f4:	6ba2                	ld	s7,8(sp)
    800021f6:	6161                	addi	sp,sp,80
    800021f8:	8082                	ret
            release(&pp->lock);
    800021fa:	8526                	mv	a0,s1
    800021fc:	a99fe0ef          	jal	80000c94 <release>
            release(&wait_lock);
    80002200:	00010517          	auipc	a0,0x10
    80002204:	1c050513          	addi	a0,a0,448 # 800123c0 <wait_lock>
    80002208:	a8dfe0ef          	jal	80000c94 <release>
            return -1;
    8000220c:	59fd                	li	s3,-1
    8000220e:	bfd1                	j	800021e2 <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002210:	16848493          	addi	s1,s1,360
    80002214:	03348063          	beq	s1,s3,80002234 <kwait+0xc6>
      if (pp->parent == p) {
    80002218:	7c9c                	ld	a5,56(s1)
    8000221a:	ff279be3          	bne	a5,s2,80002210 <kwait+0xa2>
        acquire(&pp->lock);
    8000221e:	8526                	mv	a0,s1
    80002220:	9e5fe0ef          	jal	80000c04 <acquire>
        if (pp->state == ZOMBIE) {
    80002224:	4c9c                	lw	a5,24(s1)
    80002226:	f94784e3          	beq	a5,s4,800021ae <kwait+0x40>
        release(&pp->lock);
    8000222a:	8526                	mv	a0,s1
    8000222c:	a69fe0ef          	jal	80000c94 <release>
        havekids = 1;
    80002230:	8756                	mv	a4,s5
    80002232:	bff9                	j	80002210 <kwait+0xa2>
    if (!havekids || killed(p)) {
    80002234:	cf19                	beqz	a4,80002252 <kwait+0xe4>
    80002236:	854a                	mv	a0,s2
    80002238:	f0dff0ef          	jal	80002144 <killed>
    8000223c:	e919                	bnez	a0,80002252 <kwait+0xe4>
    sleep(p, &wait_lock); //DOC: wait-sleep
    8000223e:	85da                	mv	a1,s6
    80002240:	854a                	mv	a0,s2
    80002242:	cc7ff0ef          	jal	80001f08 <sleep>
    havekids = 0;
    80002246:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002248:	00010497          	auipc	s1,0x10
    8000224c:	59048493          	addi	s1,s1,1424 # 800127d8 <proc>
    80002250:	b7e1                	j	80002218 <kwait+0xaa>
      release(&wait_lock);
    80002252:	00010517          	auipc	a0,0x10
    80002256:	16e50513          	addi	a0,a0,366 # 800123c0 <wait_lock>
    8000225a:	a3bfe0ef          	jal	80000c94 <release>
      return -1;
    8000225e:	59fd                	li	s3,-1
    80002260:	b749                	j	800021e2 <kwait+0x74>

0000000080002262 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002262:	7179                	addi	sp,sp,-48
    80002264:	f406                	sd	ra,40(sp)
    80002266:	f022                	sd	s0,32(sp)
    80002268:	ec26                	sd	s1,24(sp)
    8000226a:	e84a                	sd	s2,16(sp)
    8000226c:	e44e                	sd	s3,8(sp)
    8000226e:	e052                	sd	s4,0(sp)
    80002270:	1800                	addi	s0,sp,48
    80002272:	84aa                	mv	s1,a0
    80002274:	8a2e                	mv	s4,a1
    80002276:	89b2                	mv	s3,a2
    80002278:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000227a:	e88ff0ef          	jal	80001902 <myproc>
  if (user_dst) {
    8000227e:	cc99                	beqz	s1,8000229c <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002280:	86ca                	mv	a3,s2
    80002282:	864e                	mv	a2,s3
    80002284:	85d2                	mv	a1,s4
    80002286:	6928                	ld	a0,80(a0)
    80002288:	ba0ff0ef          	jal	80001628 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000228c:	70a2                	ld	ra,40(sp)
    8000228e:	7402                	ld	s0,32(sp)
    80002290:	64e2                	ld	s1,24(sp)
    80002292:	6942                	ld	s2,16(sp)
    80002294:	69a2                	ld	s3,8(sp)
    80002296:	6a02                	ld	s4,0(sp)
    80002298:	6145                	addi	sp,sp,48
    8000229a:	8082                	ret
    memmove((char *)dst, src, len);
    8000229c:	0009061b          	sext.w	a2,s2
    800022a0:	85ce                	mv	a1,s3
    800022a2:	8552                	mv	a0,s4
    800022a4:	a89fe0ef          	jal	80000d2c <memmove>
    return 0;
    800022a8:	8526                	mv	a0,s1
    800022aa:	b7cd                	j	8000228c <either_copyout+0x2a>

00000000800022ac <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022ac:	7179                	addi	sp,sp,-48
    800022ae:	f406                	sd	ra,40(sp)
    800022b0:	f022                	sd	s0,32(sp)
    800022b2:	ec26                	sd	s1,24(sp)
    800022b4:	e84a                	sd	s2,16(sp)
    800022b6:	e44e                	sd	s3,8(sp)
    800022b8:	e052                	sd	s4,0(sp)
    800022ba:	1800                	addi	s0,sp,48
    800022bc:	8a2a                	mv	s4,a0
    800022be:	84ae                	mv	s1,a1
    800022c0:	89b2                	mv	s3,a2
    800022c2:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022c4:	e3eff0ef          	jal	80001902 <myproc>
  if (user_src) {
    800022c8:	cc99                	beqz	s1,800022e6 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022ca:	86ca                	mv	a3,s2
    800022cc:	864e                	mv	a2,s3
    800022ce:	85d2                	mv	a1,s4
    800022d0:	6928                	ld	a0,80(a0)
    800022d2:	c14ff0ef          	jal	800016e6 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800022d6:	70a2                	ld	ra,40(sp)
    800022d8:	7402                	ld	s0,32(sp)
    800022da:	64e2                	ld	s1,24(sp)
    800022dc:	6942                	ld	s2,16(sp)
    800022de:	69a2                	ld	s3,8(sp)
    800022e0:	6a02                	ld	s4,0(sp)
    800022e2:	6145                	addi	sp,sp,48
    800022e4:	8082                	ret
    memmove(dst, (char *)src, len);
    800022e6:	0009061b          	sext.w	a2,s2
    800022ea:	85ce                	mv	a1,s3
    800022ec:	8552                	mv	a0,s4
    800022ee:	a3ffe0ef          	jal	80000d2c <memmove>
    return 0;
    800022f2:	8526                	mv	a0,s1
    800022f4:	b7cd                	j	800022d6 <either_copyin+0x2a>

00000000800022f6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022f6:	715d                	addi	sp,sp,-80
    800022f8:	e486                	sd	ra,72(sp)
    800022fa:	e0a2                	sd	s0,64(sp)
    800022fc:	fc26                	sd	s1,56(sp)
    800022fe:	f84a                	sd	s2,48(sp)
    80002300:	f44e                	sd	s3,40(sp)
    80002302:	f052                	sd	s4,32(sp)
    80002304:	ec56                	sd	s5,24(sp)
    80002306:	e85a                	sd	s6,16(sp)
    80002308:	e45e                	sd	s7,8(sp)
    8000230a:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    8000230c:	00005517          	auipc	a0,0x5
    80002310:	d6c50513          	addi	a0,a0,-660 # 80007078 <etext+0x78>
    80002314:	9dafe0ef          	jal	800004ee <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002318:	00010497          	auipc	s1,0x10
    8000231c:	61848493          	addi	s1,s1,1560 # 80012930 <proc+0x158>
    80002320:	00016917          	auipc	s2,0x16
    80002324:	01090913          	addi	s2,s2,16 # 80018330 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002328:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000232a:	00005997          	auipc	s3,0x5
    8000232e:	ed698993          	addi	s3,s3,-298 # 80007200 <etext+0x200>
    printk("%d %s %s", p->pid, state, p->name);
    80002332:	00005a97          	auipc	s5,0x5
    80002336:	ed6a8a93          	addi	s5,s5,-298 # 80007208 <etext+0x208>
    printk("\n");
    8000233a:	00005a17          	auipc	s4,0x5
    8000233e:	d3ea0a13          	addi	s4,s4,-706 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002342:	00005b97          	auipc	s7,0x5
    80002346:	3e6b8b93          	addi	s7,s7,998 # 80007728 <states.0>
    8000234a:	a829                	j	80002364 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    8000234c:	ed86a583          	lw	a1,-296(a3)
    80002350:	8556                	mv	a0,s5
    80002352:	99cfe0ef          	jal	800004ee <printk>
    printk("\n");
    80002356:	8552                	mv	a0,s4
    80002358:	996fe0ef          	jal	800004ee <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000235c:	16848493          	addi	s1,s1,360
    80002360:	03248263          	beq	s1,s2,80002384 <procdump+0x8e>
    if (p->state == UNUSED)
    80002364:	86a6                	mv	a3,s1
    80002366:	ec04a783          	lw	a5,-320(s1)
    8000236a:	dbed                	beqz	a5,8000235c <procdump+0x66>
      state = "???";
    8000236c:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000236e:	fcfb6fe3          	bltu	s6,a5,8000234c <procdump+0x56>
    80002372:	02079713          	slli	a4,a5,0x20
    80002376:	01d75793          	srli	a5,a4,0x1d
    8000237a:	97de                	add	a5,a5,s7
    8000237c:	6390                	ld	a2,0(a5)
    8000237e:	f679                	bnez	a2,8000234c <procdump+0x56>
      state = "???";
    80002380:	864e                	mv	a2,s3
    80002382:	b7e9                	j	8000234c <procdump+0x56>
  }
}
    80002384:	60a6                	ld	ra,72(sp)
    80002386:	6406                	ld	s0,64(sp)
    80002388:	74e2                	ld	s1,56(sp)
    8000238a:	7942                	ld	s2,48(sp)
    8000238c:	79a2                	ld	s3,40(sp)
    8000238e:	7a02                	ld	s4,32(sp)
    80002390:	6ae2                	ld	s5,24(sp)
    80002392:	6b42                	ld	s6,16(sp)
    80002394:	6ba2                	ld	s7,8(sp)
    80002396:	6161                	addi	sp,sp,80
    80002398:	8082                	ret

000000008000239a <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000239a:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000239e:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023a2:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023a4:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023a6:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023aa:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023ae:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023b2:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023b6:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023ba:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023be:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023c2:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023c6:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023ca:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023ce:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023d2:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023d6:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023d8:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023da:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023de:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023e2:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023e6:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023ea:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023ee:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023f2:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023f6:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023fa:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023fe:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002402:	8082                	ret

0000000080002404 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002404:	1141                	addi	sp,sp,-16
    80002406:	e406                	sd	ra,8(sp)
    80002408:	e022                	sd	s0,0(sp)
    8000240a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000240c:	00005597          	auipc	a1,0x5
    80002410:	e3c58593          	addi	a1,a1,-452 # 80007248 <etext+0x248>
    80002414:	00016517          	auipc	a0,0x16
    80002418:	dc450513          	addi	a0,a0,-572 # 800181d8 <tickslock>
    8000241c:	f5efe0ef          	jal	80000b7a <initlock>
}
    80002420:	60a2                	ld	ra,8(sp)
    80002422:	6402                	ld	s0,0(sp)
    80002424:	0141                	addi	sp,sp,16
    80002426:	8082                	ret

0000000080002428 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002428:	1141                	addi	sp,sp,-16
    8000242a:	e406                	sd	ra,8(sp)
    8000242c:	e022                	sd	s0,0(sp)
    8000242e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002430:	00003797          	auipc	a5,0x3
    80002434:	03078793          	addi	a5,a5,48 # 80005460 <kernelvec>
    80002438:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000243c:	60a2                	ld	ra,8(sp)
    8000243e:	6402                	ld	s0,0(sp)
    80002440:	0141                	addi	sp,sp,16
    80002442:	8082                	ret

0000000080002444 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002444:	1141                	addi	sp,sp,-16
    80002446:	e406                	sd	ra,8(sp)
    80002448:	e022                	sd	s0,0(sp)
    8000244a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000244c:	cb6ff0ef          	jal	80001902 <myproc>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002450:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002454:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002456:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000245a:	04000737          	lui	a4,0x4000
    8000245e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002460:	0732                	slli	a4,a4,0xc
    80002462:	00004797          	auipc	a5,0x4
    80002466:	b9e78793          	addi	a5,a5,-1122 # 80006000 <_trampoline>
    8000246a:	00004697          	auipc	a3,0x4
    8000246e:	b9668693          	addi	a3,a3,-1130 # 80006000 <_trampoline>
    80002472:	8f95                	sub	a5,a5,a3
    80002474:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002476:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000247a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000247c:	18002773          	csrr	a4,satp
    80002480:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002482:	6d38                	ld	a4,88(a0)
    80002484:	613c                	ld	a5,64(a0)
    80002486:	6685                	lui	a3,0x1
    80002488:	97b6                	add	a5,a5,a3
    8000248a:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000248c:	6d3c                	ld	a5,88(a0)
    8000248e:	00000717          	auipc	a4,0x0
    80002492:	0fc70713          	addi	a4,a4,252 # 8000258a <usertrap>
    80002496:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002498:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000249a:	8712                	mv	a4,tp
    8000249c:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000249e:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024a2:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024a6:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800024aa:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024ae:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800024b0:	6f9c                	ld	a5,24(a5)
    800024b2:	14179073          	csrw	sepc,a5
}
    800024b6:	60a2                	ld	ra,8(sp)
    800024b8:	6402                	ld	s0,0(sp)
    800024ba:	0141                	addi	sp,sp,16
    800024bc:	8082                	ret

00000000800024be <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024be:	1141                	addi	sp,sp,-16
    800024c0:	e406                	sd	ra,8(sp)
    800024c2:	e022                	sd	s0,0(sp)
    800024c4:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800024c6:	c08ff0ef          	jal	800018ce <cpuid>
    800024ca:	cd11                	beqz	a0,800024e6 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800024cc:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024d0:	000f4737          	lui	a4,0xf4
    800024d4:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024d8:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800024da:	14d79073          	csrw	stimecmp,a5
}
    800024de:	60a2                	ld	ra,8(sp)
    800024e0:	6402                	ld	s0,0(sp)
    800024e2:	0141                	addi	sp,sp,16
    800024e4:	8082                	ret
    acquire(&tickslock);
    800024e6:	00016517          	auipc	a0,0x16
    800024ea:	cf250513          	addi	a0,a0,-782 # 800181d8 <tickslock>
    800024ee:	f16fe0ef          	jal	80000c04 <acquire>
    ticks++;
    800024f2:	00008717          	auipc	a4,0x8
    800024f6:	db670713          	addi	a4,a4,-586 # 8000a2a8 <ticks>
    800024fa:	431c                	lw	a5,0(a4)
    800024fc:	2785                	addiw	a5,a5,1
    800024fe:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002500:	853a                	mv	a0,a4
    80002502:	a53ff0ef          	jal	80001f54 <wakeup>
    release(&tickslock);
    80002506:	00016517          	auipc	a0,0x16
    8000250a:	cd250513          	addi	a0,a0,-814 # 800181d8 <tickslock>
    8000250e:	f86fe0ef          	jal	80000c94 <release>
    80002512:	bf6d                	j	800024cc <clockintr+0xe>

0000000080002514 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002514:	1101                	addi	sp,sp,-32
    80002516:	ec06                	sd	ra,24(sp)
    80002518:	e822                	sd	s0,16(sp)
    8000251a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000251c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002520:	57fd                	li	a5,-1
    80002522:	17fe                	slli	a5,a5,0x3f
    80002524:	07a5                	addi	a5,a5,9
    80002526:	00f70c63          	beq	a4,a5,8000253e <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000252a:	57fd                	li	a5,-1
    8000252c:	17fe                	slli	a5,a5,0x3f
    8000252e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002530:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002532:	04f70863          	beq	a4,a5,80002582 <devintr+0x6e>
  }
}
    80002536:	60e2                	ld	ra,24(sp)
    80002538:	6442                	ld	s0,16(sp)
    8000253a:	6105                	addi	sp,sp,32
    8000253c:	8082                	ret
    8000253e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002540:	7cd020ef          	jal	8000550c <plic_claim>
    80002544:	872a                	mv	a4,a0
    80002546:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002548:	47a9                	li	a5,10
    8000254a:	00f50963          	beq	a0,a5,8000255c <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000254e:	4785                	li	a5,1
    80002550:	00f50963          	beq	a0,a5,80002562 <devintr+0x4e>
    return 1;
    80002554:	4505                	li	a0,1
    } else if (irq) {
    80002556:	eb09                	bnez	a4,80002568 <devintr+0x54>
    80002558:	64a2                	ld	s1,8(sp)
    8000255a:	bff1                	j	80002536 <devintr+0x22>
      uartintr();
    8000255c:	c64fe0ef          	jal	800009c0 <uartintr>
    if (irq)
    80002560:	a819                	j	80002576 <devintr+0x62>
      virtio_disk_intr();
    80002562:	440030ef          	jal	800059a2 <virtio_disk_intr>
    if (irq)
    80002566:	a801                	j	80002576 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    80002568:	85ba                	mv	a1,a4
    8000256a:	00005517          	auipc	a0,0x5
    8000256e:	ce650513          	addi	a0,a0,-794 # 80007250 <etext+0x250>
    80002572:	f7dfd0ef          	jal	800004ee <printk>
      plic_complete(irq);
    80002576:	8526                	mv	a0,s1
    80002578:	7b5020ef          	jal	8000552c <plic_complete>
    return 1;
    8000257c:	4505                	li	a0,1
    8000257e:	64a2                	ld	s1,8(sp)
    80002580:	bf5d                	j	80002536 <devintr+0x22>
    clockintr();
    80002582:	f3dff0ef          	jal	800024be <clockintr>
    return 2;
    80002586:	4509                	li	a0,2
    80002588:	b77d                	j	80002536 <devintr+0x22>

000000008000258a <usertrap>:
{
    8000258a:	1101                	addi	sp,sp,-32
    8000258c:	ec06                	sd	ra,24(sp)
    8000258e:	e822                	sd	s0,16(sp)
    80002590:	e426                	sd	s1,8(sp)
    80002592:	e04a                	sd	s2,0(sp)
    80002594:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002596:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000259a:	1007f793          	andi	a5,a5,256
    8000259e:	eba5                	bnez	a5,8000260e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025a0:	00003797          	auipc	a5,0x3
    800025a4:	ec078793          	addi	a5,a5,-320 # 80005460 <kernelvec>
    800025a8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025ac:	b56ff0ef          	jal	80001902 <myproc>
    800025b0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025b2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800025b4:	14102773          	csrr	a4,sepc
    800025b8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800025ba:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800025be:	47a1                	li	a5,8
    800025c0:	04f70d63          	beq	a4,a5,8000261a <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800025c4:	f51ff0ef          	jal	80002514 <devintr>
    800025c8:	892a                	mv	s2,a0
    800025ca:	e945                	bnez	a0,8000267a <usertrap+0xf0>
    800025cc:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800025d0:	47bd                	li	a5,15
    800025d2:	08f70863          	beq	a4,a5,80002662 <usertrap+0xd8>
    800025d6:	14202773          	csrr	a4,scause
    800025da:	47b5                	li	a5,13
    800025dc:	08f70363          	beq	a4,a5,80002662 <usertrap+0xd8>
    800025e0:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025e4:	5890                	lw	a2,48(s1)
    800025e6:	00005517          	auipc	a0,0x5
    800025ea:	caa50513          	addi	a0,a0,-854 # 80007290 <etext+0x290>
    800025ee:	f01fd0ef          	jal	800004ee <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800025f2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800025f6:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025fa:	00005517          	auipc	a0,0x5
    800025fe:	cc650513          	addi	a0,a0,-826 # 800072c0 <etext+0x2c0>
    80002602:	eedfd0ef          	jal	800004ee <printk>
    setkilled(p);
    80002606:	8526                	mv	a0,s1
    80002608:	b19ff0ef          	jal	80002120 <setkilled>
    8000260c:	a035                	j	80002638 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000260e:	00005517          	auipc	a0,0x5
    80002612:	c6250513          	addi	a0,a0,-926 # 80007270 <etext+0x270>
    80002616:	a02fe0ef          	jal	80000818 <panic>
    if (killed(p))
    8000261a:	b2bff0ef          	jal	80002144 <killed>
    8000261e:	ed15                	bnez	a0,8000265a <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002620:	6cb8                	ld	a4,88(s1)
    80002622:	6f1c                	ld	a5,24(a4)
    80002624:	0791                	addi	a5,a5,4
    80002626:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002628:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000262c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002630:	10079073          	csrw	sstatus,a5
    syscall();
    80002634:	240000ef          	jal	80002874 <syscall>
  if (killed(p))
    80002638:	8526                	mv	a0,s1
    8000263a:	b0bff0ef          	jal	80002144 <killed>
    8000263e:	e139                	bnez	a0,80002684 <usertrap+0xfa>
  prepare_return();
    80002640:	e05ff0ef          	jal	80002444 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002644:	68a8                	ld	a0,80(s1)
    80002646:	8131                	srli	a0,a0,0xc
    80002648:	57fd                	li	a5,-1
    8000264a:	17fe                	slli	a5,a5,0x3f
    8000264c:	8d5d                	or	a0,a0,a5
}
    8000264e:	60e2                	ld	ra,24(sp)
    80002650:	6442                	ld	s0,16(sp)
    80002652:	64a2                	ld	s1,8(sp)
    80002654:	6902                	ld	s2,0(sp)
    80002656:	6105                	addi	sp,sp,32
    80002658:	8082                	ret
      kexit(-1);
    8000265a:	557d                	li	a0,-1
    8000265c:	9b9ff0ef          	jal	80002014 <kexit>
    80002660:	b7c1                	j	80002620 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002662:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002666:	14202673          	csrr	a2,scause
             vmfault(p->pagetable, r_stval(), (r_scause() == 13) ? 1 : 0) !=
    8000266a:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000266c:	00163613          	seqz	a2,a2
    80002670:	68a8                	ld	a0,80(s1)
    80002672:	f33fe0ef          	jal	800015a4 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002676:	f169                	bnez	a0,80002638 <usertrap+0xae>
    80002678:	b7a5                	j	800025e0 <usertrap+0x56>
  if (killed(p))
    8000267a:	8526                	mv	a0,s1
    8000267c:	ac9ff0ef          	jal	80002144 <killed>
    80002680:	c511                	beqz	a0,8000268c <usertrap+0x102>
    80002682:	a011                	j	80002686 <usertrap+0xfc>
    80002684:	4901                	li	s2,0
    kexit(-1);
    80002686:	557d                	li	a0,-1
    80002688:	98dff0ef          	jal	80002014 <kexit>
  if (which_dev == 2)
    8000268c:	4789                	li	a5,2
    8000268e:	faf919e3          	bne	s2,a5,80002640 <usertrap+0xb6>
    yield();
    80002692:	84bff0ef          	jal	80001edc <yield>
    80002696:	b76d                	j	80002640 <usertrap+0xb6>

0000000080002698 <kerneltrap>:
{
    80002698:	7179                	addi	sp,sp,-48
    8000269a:	f406                	sd	ra,40(sp)
    8000269c:	f022                	sd	s0,32(sp)
    8000269e:	ec26                	sd	s1,24(sp)
    800026a0:	e84a                	sd	s2,16(sp)
    800026a2:	e44e                	sd	s3,8(sp)
    800026a4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026a6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026aa:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800026ae:	142027f3          	csrr	a5,scause
    800026b2:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800026b4:	1004f793          	andi	a5,s1,256
    800026b8:	c795                	beqz	a5,800026e4 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026ba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026be:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800026c0:	eb85                	bnez	a5,800026f0 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800026c2:	e53ff0ef          	jal	80002514 <devintr>
    800026c6:	c91d                	beqz	a0,800026fc <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800026c8:	4789                	li	a5,2
    800026ca:	04f50a63          	beq	a0,a5,8000271e <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800026ce:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800026d2:	10049073          	csrw	sstatus,s1
}
    800026d6:	70a2                	ld	ra,40(sp)
    800026d8:	7402                	ld	s0,32(sp)
    800026da:	64e2                	ld	s1,24(sp)
    800026dc:	6942                	ld	s2,16(sp)
    800026de:	69a2                	ld	s3,8(sp)
    800026e0:	6145                	addi	sp,sp,48
    800026e2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026e4:	00005517          	auipc	a0,0x5
    800026e8:	c0450513          	addi	a0,a0,-1020 # 800072e8 <etext+0x2e8>
    800026ec:	92cfe0ef          	jal	80000818 <panic>
    panic("kerneltrap: interrupts enabled");
    800026f0:	00005517          	auipc	a0,0x5
    800026f4:	c2050513          	addi	a0,a0,-992 # 80007310 <etext+0x310>
    800026f8:	920fe0ef          	jal	80000818 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026fc:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002700:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002704:	85ce                	mv	a1,s3
    80002706:	00005517          	auipc	a0,0x5
    8000270a:	c2a50513          	addi	a0,a0,-982 # 80007330 <etext+0x330>
    8000270e:	de1fd0ef          	jal	800004ee <printk>
    panic("kerneltrap");
    80002712:	00005517          	auipc	a0,0x5
    80002716:	c4650513          	addi	a0,a0,-954 # 80007358 <etext+0x358>
    8000271a:	8fefe0ef          	jal	80000818 <panic>
  if (which_dev == 2 && myproc() != 0)
    8000271e:	9e4ff0ef          	jal	80001902 <myproc>
    80002722:	d555                	beqz	a0,800026ce <kerneltrap+0x36>
    yield();
    80002724:	fb8ff0ef          	jal	80001edc <yield>
    80002728:	b75d                	j	800026ce <kerneltrap+0x36>

000000008000272a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000272a:	1101                	addi	sp,sp,-32
    8000272c:	ec06                	sd	ra,24(sp)
    8000272e:	e822                	sd	s0,16(sp)
    80002730:	e426                	sd	s1,8(sp)
    80002732:	1000                	addi	s0,sp,32
    80002734:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002736:	9ccff0ef          	jal	80001902 <myproc>
  switch (n) {
    8000273a:	4795                	li	a5,5
    8000273c:	0497e163          	bltu	a5,s1,8000277e <argraw+0x54>
    80002740:	048a                	slli	s1,s1,0x2
    80002742:	00005717          	auipc	a4,0x5
    80002746:	01670713          	addi	a4,a4,22 # 80007758 <states.0+0x30>
    8000274a:	94ba                	add	s1,s1,a4
    8000274c:	409c                	lw	a5,0(s1)
    8000274e:	97ba                	add	a5,a5,a4
    80002750:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002752:	6d3c                	ld	a5,88(a0)
    80002754:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002756:	60e2                	ld	ra,24(sp)
    80002758:	6442                	ld	s0,16(sp)
    8000275a:	64a2                	ld	s1,8(sp)
    8000275c:	6105                	addi	sp,sp,32
    8000275e:	8082                	ret
    return p->trapframe->a1;
    80002760:	6d3c                	ld	a5,88(a0)
    80002762:	7fa8                	ld	a0,120(a5)
    80002764:	bfcd                	j	80002756 <argraw+0x2c>
    return p->trapframe->a2;
    80002766:	6d3c                	ld	a5,88(a0)
    80002768:	63c8                	ld	a0,128(a5)
    8000276a:	b7f5                	j	80002756 <argraw+0x2c>
    return p->trapframe->a3;
    8000276c:	6d3c                	ld	a5,88(a0)
    8000276e:	67c8                	ld	a0,136(a5)
    80002770:	b7dd                	j	80002756 <argraw+0x2c>
    return p->trapframe->a4;
    80002772:	6d3c                	ld	a5,88(a0)
    80002774:	6bc8                	ld	a0,144(a5)
    80002776:	b7c5                	j	80002756 <argraw+0x2c>
    return p->trapframe->a5;
    80002778:	6d3c                	ld	a5,88(a0)
    8000277a:	6fc8                	ld	a0,152(a5)
    8000277c:	bfe9                	j	80002756 <argraw+0x2c>
  panic("argraw");
    8000277e:	00005517          	auipc	a0,0x5
    80002782:	bea50513          	addi	a0,a0,-1046 # 80007368 <etext+0x368>
    80002786:	892fe0ef          	jal	80000818 <panic>

000000008000278a <fetchaddr>:
{
    8000278a:	1101                	addi	sp,sp,-32
    8000278c:	ec06                	sd	ra,24(sp)
    8000278e:	e822                	sd	s0,16(sp)
    80002790:	e426                	sd	s1,8(sp)
    80002792:	e04a                	sd	s2,0(sp)
    80002794:	1000                	addi	s0,sp,32
    80002796:	84aa                	mv	s1,a0
    80002798:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000279a:	968ff0ef          	jal	80001902 <myproc>
  if (addr >= p->sz ||
    8000279e:	653c                	ld	a5,72(a0)
    800027a0:	02f4f663          	bgeu	s1,a5,800027cc <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027a4:	00848713          	addi	a4,s1,8
  if (addr >= p->sz ||
    800027a8:	02e7e463          	bltu	a5,a4,800027d0 <fetchaddr+0x46>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027ac:	46a1                	li	a3,8
    800027ae:	8626                	mv	a2,s1
    800027b0:	85ca                	mv	a1,s2
    800027b2:	6928                	ld	a0,80(a0)
    800027b4:	f33fe0ef          	jal	800016e6 <copyin>
    800027b8:	00a03533          	snez	a0,a0
    800027bc:	40a0053b          	negw	a0,a0
}
    800027c0:	60e2                	ld	ra,24(sp)
    800027c2:	6442                	ld	s0,16(sp)
    800027c4:	64a2                	ld	s1,8(sp)
    800027c6:	6902                	ld	s2,0(sp)
    800027c8:	6105                	addi	sp,sp,32
    800027ca:	8082                	ret
    return -1;
    800027cc:	557d                	li	a0,-1
    800027ce:	bfcd                	j	800027c0 <fetchaddr+0x36>
    800027d0:	557d                	li	a0,-1
    800027d2:	b7fd                	j	800027c0 <fetchaddr+0x36>

00000000800027d4 <fetchstr>:
{
    800027d4:	7179                	addi	sp,sp,-48
    800027d6:	f406                	sd	ra,40(sp)
    800027d8:	f022                	sd	s0,32(sp)
    800027da:	ec26                	sd	s1,24(sp)
    800027dc:	e84a                	sd	s2,16(sp)
    800027de:	e44e                	sd	s3,8(sp)
    800027e0:	1800                	addi	s0,sp,48
    800027e2:	89aa                	mv	s3,a0
    800027e4:	84ae                	mv	s1,a1
    800027e6:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800027e8:	91aff0ef          	jal	80001902 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800027ec:	86ca                	mv	a3,s2
    800027ee:	864e                	mv	a2,s3
    800027f0:	85a6                	mv	a1,s1
    800027f2:	6928                	ld	a0,80(a0)
    800027f4:	cd9fe0ef          	jal	800014cc <copyinstr>
    800027f8:	00054c63          	bltz	a0,80002810 <fetchstr+0x3c>
  return strlen(buf);
    800027fc:	8526                	mv	a0,s1
    800027fe:	e58fe0ef          	jal	80000e56 <strlen>
}
    80002802:	70a2                	ld	ra,40(sp)
    80002804:	7402                	ld	s0,32(sp)
    80002806:	64e2                	ld	s1,24(sp)
    80002808:	6942                	ld	s2,16(sp)
    8000280a:	69a2                	ld	s3,8(sp)
    8000280c:	6145                	addi	sp,sp,48
    8000280e:	8082                	ret
    return -1;
    80002810:	557d                	li	a0,-1
    80002812:	bfc5                	j	80002802 <fetchstr+0x2e>

0000000080002814 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002814:	1101                	addi	sp,sp,-32
    80002816:	ec06                	sd	ra,24(sp)
    80002818:	e822                	sd	s0,16(sp)
    8000281a:	e426                	sd	s1,8(sp)
    8000281c:	1000                	addi	s0,sp,32
    8000281e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002820:	f0bff0ef          	jal	8000272a <argraw>
    80002824:	c088                	sw	a0,0(s1)
}
    80002826:	60e2                	ld	ra,24(sp)
    80002828:	6442                	ld	s0,16(sp)
    8000282a:	64a2                	ld	s1,8(sp)
    8000282c:	6105                	addi	sp,sp,32
    8000282e:	8082                	ret

0000000080002830 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002830:	1101                	addi	sp,sp,-32
    80002832:	ec06                	sd	ra,24(sp)
    80002834:	e822                	sd	s0,16(sp)
    80002836:	e426                	sd	s1,8(sp)
    80002838:	1000                	addi	s0,sp,32
    8000283a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000283c:	eefff0ef          	jal	8000272a <argraw>
    80002840:	e088                	sd	a0,0(s1)
}
    80002842:	60e2                	ld	ra,24(sp)
    80002844:	6442                	ld	s0,16(sp)
    80002846:	64a2                	ld	s1,8(sp)
    80002848:	6105                	addi	sp,sp,32
    8000284a:	8082                	ret

000000008000284c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000284c:	1101                	addi	sp,sp,-32
    8000284e:	ec06                	sd	ra,24(sp)
    80002850:	e822                	sd	s0,16(sp)
    80002852:	e426                	sd	s1,8(sp)
    80002854:	e04a                	sd	s2,0(sp)
    80002856:	1000                	addi	s0,sp,32
    80002858:	892e                	mv	s2,a1
    8000285a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    8000285c:	ecfff0ef          	jal	8000272a <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002860:	8626                	mv	a2,s1
    80002862:	85ca                	mv	a1,s2
    80002864:	f71ff0ef          	jal	800027d4 <fetchstr>
}
    80002868:	60e2                	ld	ra,24(sp)
    8000286a:	6442                	ld	s0,16(sp)
    8000286c:	64a2                	ld	s1,8(sp)
    8000286e:	6902                	ld	s2,0(sp)
    80002870:	6105                	addi	sp,sp,32
    80002872:	8082                	ret

0000000080002874 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002874:	1101                	addi	sp,sp,-32
    80002876:	ec06                	sd	ra,24(sp)
    80002878:	e822                	sd	s0,16(sp)
    8000287a:	e426                	sd	s1,8(sp)
    8000287c:	e04a                	sd	s2,0(sp)
    8000287e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002880:	882ff0ef          	jal	80001902 <myproc>
    80002884:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002886:	05853903          	ld	s2,88(a0)
    8000288a:	0a893783          	ld	a5,168(s2)
    8000288e:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002892:	37fd                	addiw	a5,a5,-1
    80002894:	475d                	li	a4,23
    80002896:	00f76f63          	bltu	a4,a5,800028b4 <syscall+0x40>
    8000289a:	00369713          	slli	a4,a3,0x3
    8000289e:	00005797          	auipc	a5,0x5
    800028a2:	ed278793          	addi	a5,a5,-302 # 80007770 <syscalls>
    800028a6:	97ba                	add	a5,a5,a4
    800028a8:	639c                	ld	a5,0(a5)
    800028aa:	c789                	beqz	a5,800028b4 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028ac:	9782                	jalr	a5
    800028ae:	06a93823          	sd	a0,112(s2)
    800028b2:	a829                	j	800028cc <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800028b4:	15848613          	addi	a2,s1,344
    800028b8:	588c                	lw	a1,48(s1)
    800028ba:	00005517          	auipc	a0,0x5
    800028be:	ab650513          	addi	a0,a0,-1354 # 80007370 <etext+0x370>
    800028c2:	c2dfd0ef          	jal	800004ee <printk>
    p->trapframe->a0 = -1;
    800028c6:	6cbc                	ld	a5,88(s1)
    800028c8:	577d                	li	a4,-1
    800028ca:	fbb8                	sd	a4,112(a5)
  }
}
    800028cc:	60e2                	ld	ra,24(sp)
    800028ce:	6442                	ld	s0,16(sp)
    800028d0:	64a2                	ld	s1,8(sp)
    800028d2:	6902                	ld	s2,0(sp)
    800028d4:	6105                	addi	sp,sp,32
    800028d6:	8082                	ret

00000000800028d8 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028d8:	1101                	addi	sp,sp,-32
    800028da:	ec06                	sd	ra,24(sp)
    800028dc:	e822                	sd	s0,16(sp)
    800028de:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028e0:	fec40593          	addi	a1,s0,-20
    800028e4:	4501                	li	a0,0
    800028e6:	f2fff0ef          	jal	80002814 <argint>
  kexit(n);
    800028ea:	fec42503          	lw	a0,-20(s0)
    800028ee:	f26ff0ef          	jal	80002014 <kexit>
  return 0; // not reached
}
    800028f2:	4501                	li	a0,0
    800028f4:	60e2                	ld	ra,24(sp)
    800028f6:	6442                	ld	s0,16(sp)
    800028f8:	6105                	addi	sp,sp,32
    800028fa:	8082                	ret

00000000800028fc <sys_getpid>:

uint64
sys_getpid(void)
{
    800028fc:	1141                	addi	sp,sp,-16
    800028fe:	e406                	sd	ra,8(sp)
    80002900:	e022                	sd	s0,0(sp)
    80002902:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002904:	ffffe0ef          	jal	80001902 <myproc>
}
    80002908:	5908                	lw	a0,48(a0)
    8000290a:	60a2                	ld	ra,8(sp)
    8000290c:	6402                	ld	s0,0(sp)
    8000290e:	0141                	addi	sp,sp,16
    80002910:	8082                	ret

0000000080002912 <sys_fork>:

uint64
sys_fork(void)
{
    80002912:	1141                	addi	sp,sp,-16
    80002914:	e406                	sd	ra,8(sp)
    80002916:	e022                	sd	s0,0(sp)
    80002918:	0800                	addi	s0,sp,16
  return kfork();
    8000291a:	b50ff0ef          	jal	80001c6a <kfork>
}
    8000291e:	60a2                	ld	ra,8(sp)
    80002920:	6402                	ld	s0,0(sp)
    80002922:	0141                	addi	sp,sp,16
    80002924:	8082                	ret

0000000080002926 <sys_wait>:

uint64
sys_wait(void)
{
    80002926:	1101                	addi	sp,sp,-32
    80002928:	ec06                	sd	ra,24(sp)
    8000292a:	e822                	sd	s0,16(sp)
    8000292c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000292e:	fe840593          	addi	a1,s0,-24
    80002932:	4501                	li	a0,0
    80002934:	efdff0ef          	jal	80002830 <argaddr>
  return kwait(p);
    80002938:	fe843503          	ld	a0,-24(s0)
    8000293c:	833ff0ef          	jal	8000216e <kwait>
}
    80002940:	60e2                	ld	ra,24(sp)
    80002942:	6442                	ld	s0,16(sp)
    80002944:	6105                	addi	sp,sp,32
    80002946:	8082                	ret

0000000080002948 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002948:	7179                	addi	sp,sp,-48
    8000294a:	f406                	sd	ra,40(sp)
    8000294c:	f022                	sd	s0,32(sp)
    8000294e:	ec26                	sd	s1,24(sp)
    80002950:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002952:	fd840593          	addi	a1,s0,-40
    80002956:	4501                	li	a0,0
    80002958:	ebdff0ef          	jal	80002814 <argint>
  argint(1, &t);
    8000295c:	fdc40593          	addi	a1,s0,-36
    80002960:	4505                	li	a0,1
    80002962:	eb3ff0ef          	jal	80002814 <argint>
  addr = myproc()->sz;
    80002966:	f9dfe0ef          	jal	80001902 <myproc>
    8000296a:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    8000296c:	fdc42703          	lw	a4,-36(s0)
    80002970:	4785                	li	a5,1
    80002972:	02f70763          	beq	a4,a5,800029a0 <sys_sbrk+0x58>
    80002976:	fd842783          	lw	a5,-40(s0)
    8000297a:	0207c363          	bltz	a5,800029a0 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    8000297e:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002980:	02000737          	lui	a4,0x2000
    80002984:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002986:	0736                	slli	a4,a4,0xd
    80002988:	02f76a63          	bltu	a4,a5,800029bc <sys_sbrk+0x74>
    8000298c:	0297e863          	bltu	a5,s1,800029bc <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002990:	f73fe0ef          	jal	80001902 <myproc>
    80002994:	fd842703          	lw	a4,-40(s0)
    80002998:	653c                	ld	a5,72(a0)
    8000299a:	97ba                	add	a5,a5,a4
    8000299c:	e53c                	sd	a5,72(a0)
    8000299e:	a039                	j	800029ac <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    800029a0:	fd842503          	lw	a0,-40(s0)
    800029a4:	a64ff0ef          	jal	80001c08 <growproc>
    800029a8:	00054863          	bltz	a0,800029b8 <sys_sbrk+0x70>
  }
  return addr;
}
    800029ac:	8526                	mv	a0,s1
    800029ae:	70a2                	ld	ra,40(sp)
    800029b0:	7402                	ld	s0,32(sp)
    800029b2:	64e2                	ld	s1,24(sp)
    800029b4:	6145                	addi	sp,sp,48
    800029b6:	8082                	ret
      return -1;
    800029b8:	54fd                	li	s1,-1
    800029ba:	bfcd                	j	800029ac <sys_sbrk+0x64>
      return -1;
    800029bc:	54fd                	li	s1,-1
    800029be:	b7fd                	j	800029ac <sys_sbrk+0x64>

00000000800029c0 <sys_pause>:

uint64
sys_pause(void)
{
    800029c0:	7139                	addi	sp,sp,-64
    800029c2:	fc06                	sd	ra,56(sp)
    800029c4:	f822                	sd	s0,48(sp)
    800029c6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029c8:	fcc40593          	addi	a1,s0,-52
    800029cc:	4501                	li	a0,0
    800029ce:	e47ff0ef          	jal	80002814 <argint>
  if (n < 0)
    800029d2:	fcc42783          	lw	a5,-52(s0)
    800029d6:	0607c863          	bltz	a5,80002a46 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029da:	00015517          	auipc	a0,0x15
    800029de:	7fe50513          	addi	a0,a0,2046 # 800181d8 <tickslock>
    800029e2:	a22fe0ef          	jal	80000c04 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    800029e6:	fcc42783          	lw	a5,-52(s0)
    800029ea:	c3b9                	beqz	a5,80002a30 <sys_pause+0x70>
    800029ec:	f426                	sd	s1,40(sp)
    800029ee:	f04a                	sd	s2,32(sp)
    800029f0:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    800029f2:	00008997          	auipc	s3,0x8
    800029f6:	8b69a983          	lw	s3,-1866(s3) # 8000a2a8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029fa:	00015917          	auipc	s2,0x15
    800029fe:	7de90913          	addi	s2,s2,2014 # 800181d8 <tickslock>
    80002a02:	00008497          	auipc	s1,0x8
    80002a06:	8a648493          	addi	s1,s1,-1882 # 8000a2a8 <ticks>
    if (killed(myproc())) {
    80002a0a:	ef9fe0ef          	jal	80001902 <myproc>
    80002a0e:	f36ff0ef          	jal	80002144 <killed>
    80002a12:	ed0d                	bnez	a0,80002a4c <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a14:	85ca                	mv	a1,s2
    80002a16:	8526                	mv	a0,s1
    80002a18:	cf0ff0ef          	jal	80001f08 <sleep>
  while (ticks - ticks0 < n) {
    80002a1c:	409c                	lw	a5,0(s1)
    80002a1e:	413787bb          	subw	a5,a5,s3
    80002a22:	fcc42703          	lw	a4,-52(s0)
    80002a26:	fee7e2e3          	bltu	a5,a4,80002a0a <sys_pause+0x4a>
    80002a2a:	74a2                	ld	s1,40(sp)
    80002a2c:	7902                	ld	s2,32(sp)
    80002a2e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a30:	00015517          	auipc	a0,0x15
    80002a34:	7a850513          	addi	a0,a0,1960 # 800181d8 <tickslock>
    80002a38:	a5cfe0ef          	jal	80000c94 <release>
  return 0;
    80002a3c:	4501                	li	a0,0
}
    80002a3e:	70e2                	ld	ra,56(sp)
    80002a40:	7442                	ld	s0,48(sp)
    80002a42:	6121                	addi	sp,sp,64
    80002a44:	8082                	ret
    n = 0;
    80002a46:	fc042623          	sw	zero,-52(s0)
    80002a4a:	bf41                	j	800029da <sys_pause+0x1a>
      release(&tickslock);
    80002a4c:	00015517          	auipc	a0,0x15
    80002a50:	78c50513          	addi	a0,a0,1932 # 800181d8 <tickslock>
    80002a54:	a40fe0ef          	jal	80000c94 <release>
      return -1;
    80002a58:	557d                	li	a0,-1
    80002a5a:	74a2                	ld	s1,40(sp)
    80002a5c:	7902                	ld	s2,32(sp)
    80002a5e:	69e2                	ld	s3,24(sp)
    80002a60:	bff9                	j	80002a3e <sys_pause+0x7e>

0000000080002a62 <sys_kill>:

uint64
sys_kill(void)
{
    80002a62:	1101                	addi	sp,sp,-32
    80002a64:	ec06                	sd	ra,24(sp)
    80002a66:	e822                	sd	s0,16(sp)
    80002a68:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a6a:	fec40593          	addi	a1,s0,-20
    80002a6e:	4501                	li	a0,0
    80002a70:	da5ff0ef          	jal	80002814 <argint>
  return kkill(pid);
    80002a74:	fec42503          	lw	a0,-20(s0)
    80002a78:	e42ff0ef          	jal	800020ba <kkill>
}
    80002a7c:	60e2                	ld	ra,24(sp)
    80002a7e:	6442                	ld	s0,16(sp)
    80002a80:	6105                	addi	sp,sp,32
    80002a82:	8082                	ret

0000000080002a84 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a84:	1101                	addi	sp,sp,-32
    80002a86:	ec06                	sd	ra,24(sp)
    80002a88:	e822                	sd	s0,16(sp)
    80002a8a:	e426                	sd	s1,8(sp)
    80002a8c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a8e:	00015517          	auipc	a0,0x15
    80002a92:	74a50513          	addi	a0,a0,1866 # 800181d8 <tickslock>
    80002a96:	96efe0ef          	jal	80000c04 <acquire>
  xticks = ticks;
    80002a9a:	00008797          	auipc	a5,0x8
    80002a9e:	80e7a783          	lw	a5,-2034(a5) # 8000a2a8 <ticks>
    80002aa2:	84be                	mv	s1,a5
  release(&tickslock);
    80002aa4:	00015517          	auipc	a0,0x15
    80002aa8:	73450513          	addi	a0,a0,1844 # 800181d8 <tickslock>
    80002aac:	9e8fe0ef          	jal	80000c94 <release>
  return xticks;
}
    80002ab0:	02049513          	slli	a0,s1,0x20
    80002ab4:	9101                	srli	a0,a0,0x20
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	64a2                	ld	s1,8(sp)
    80002abc:	6105                	addi	sp,sp,32
    80002abe:	8082                	ret

0000000080002ac0 <sys_getidade>:

uint64
sys_getidade(void)
{
    80002ac0:	1141                	addi	sp,sp,-16
    80002ac2:	e406                	sd	ra,8(sp)
    80002ac4:	e022                	sd	s0,0(sp)
    80002ac6:	0800                	addi	s0,sp,16
  
  return 2026;
}
    80002ac8:	7ea00513          	li	a0,2026
    80002acc:	60a2                	ld	ra,8(sp)
    80002ace:	6402                	ld	s0,0(sp)
    80002ad0:	0141                	addi	sp,sp,16
    80002ad2:	8082                	ret

0000000080002ad4 <sys_getppid>:

uint64
sys_getppid(void)
{
    80002ad4:	1141                	addi	sp,sp,-16
    80002ad6:	e406                	sd	ra,8(sp)
    80002ad8:	e022                	sd	s0,0(sp)
    80002ada:	0800                	addi	s0,sp,16
  struct proc *p = myproc(); 
    80002adc:	e27fe0ef          	jal	80001902 <myproc>
  if (p->parent != 0) {
    80002ae0:	7d1c                	ld	a5,56(a0)
    return p->parent->pid; 
  }
  
  return 1;
    80002ae2:	4505                	li	a0,1
  if (p->parent != 0) {
    80002ae4:	c391                	beqz	a5,80002ae8 <sys_getppid+0x14>
    return p->parent->pid; 
    80002ae6:	5b88                	lw	a0,48(a5)
    80002ae8:	60a2                	ld	ra,8(sp)
    80002aea:	6402                	ld	s0,0(sp)
    80002aec:	0141                	addi	sp,sp,16
    80002aee:	8082                	ret

0000000080002af0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002af0:	7179                	addi	sp,sp,-48
    80002af2:	f406                	sd	ra,40(sp)
    80002af4:	f022                	sd	s0,32(sp)
    80002af6:	ec26                	sd	s1,24(sp)
    80002af8:	e84a                	sd	s2,16(sp)
    80002afa:	e44e                	sd	s3,8(sp)
    80002afc:	e052                	sd	s4,0(sp)
    80002afe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b00:	00005597          	auipc	a1,0x5
    80002b04:	89058593          	addi	a1,a1,-1904 # 80007390 <etext+0x390>
    80002b08:	00015517          	auipc	a0,0x15
    80002b0c:	6e850513          	addi	a0,a0,1768 # 800181f0 <bcache>
    80002b10:	86afe0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b14:	0001d797          	auipc	a5,0x1d
    80002b18:	6dc78793          	addi	a5,a5,1756 # 800201f0 <bcache+0x8000>
    80002b1c:	0001e717          	auipc	a4,0x1e
    80002b20:	93c70713          	addi	a4,a4,-1732 # 80020458 <bcache+0x8268>
    80002b24:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b28:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b2c:	00015497          	auipc	s1,0x15
    80002b30:	6dc48493          	addi	s1,s1,1756 # 80018208 <bcache+0x18>
    b->next = bcache.head.next;
    80002b34:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b36:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b38:	00005a17          	auipc	s4,0x5
    80002b3c:	860a0a13          	addi	s4,s4,-1952 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002b40:	2b893783          	ld	a5,696(s2)
    80002b44:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b46:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b4a:	85d2                	mv	a1,s4
    80002b4c:	01048513          	addi	a0,s1,16
    80002b50:	386010ef          	jal	80003ed6 <initsleeplock>
    bcache.head.next->prev = b;
    80002b54:	2b893783          	ld	a5,696(s2)
    80002b58:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b5a:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b5e:	45848493          	addi	s1,s1,1112
    80002b62:	fd349fe3          	bne	s1,s3,80002b40 <binit+0x50>
  }
}
    80002b66:	70a2                	ld	ra,40(sp)
    80002b68:	7402                	ld	s0,32(sp)
    80002b6a:	64e2                	ld	s1,24(sp)
    80002b6c:	6942                	ld	s2,16(sp)
    80002b6e:	69a2                	ld	s3,8(sp)
    80002b70:	6a02                	ld	s4,0(sp)
    80002b72:	6145                	addi	sp,sp,48
    80002b74:	8082                	ret

0000000080002b76 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002b76:	7179                	addi	sp,sp,-48
    80002b78:	f406                	sd	ra,40(sp)
    80002b7a:	f022                	sd	s0,32(sp)
    80002b7c:	ec26                	sd	s1,24(sp)
    80002b7e:	e84a                	sd	s2,16(sp)
    80002b80:	e44e                	sd	s3,8(sp)
    80002b82:	1800                	addi	s0,sp,48
    80002b84:	892a                	mv	s2,a0
    80002b86:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b88:	00015517          	auipc	a0,0x15
    80002b8c:	66850513          	addi	a0,a0,1640 # 800181f0 <bcache>
    80002b90:	874fe0ef          	jal	80000c04 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002b94:	0001e497          	auipc	s1,0x1e
    80002b98:	9144b483          	ld	s1,-1772(s1) # 800204a8 <bcache+0x82b8>
    80002b9c:	0001e797          	auipc	a5,0x1e
    80002ba0:	8bc78793          	addi	a5,a5,-1860 # 80020458 <bcache+0x8268>
    80002ba4:	02f48b63          	beq	s1,a5,80002bda <bread+0x64>
    80002ba8:	873e                	mv	a4,a5
    80002baa:	a021                	j	80002bb2 <bread+0x3c>
    80002bac:	68a4                	ld	s1,80(s1)
    80002bae:	02e48663          	beq	s1,a4,80002bda <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002bb2:	449c                	lw	a5,8(s1)
    80002bb4:	ff279ce3          	bne	a5,s2,80002bac <bread+0x36>
    80002bb8:	44dc                	lw	a5,12(s1)
    80002bba:	ff3799e3          	bne	a5,s3,80002bac <bread+0x36>
      b->refcnt++;
    80002bbe:	40bc                	lw	a5,64(s1)
    80002bc0:	2785                	addiw	a5,a5,1
    80002bc2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bc4:	00015517          	auipc	a0,0x15
    80002bc8:	62c50513          	addi	a0,a0,1580 # 800181f0 <bcache>
    80002bcc:	8c8fe0ef          	jal	80000c94 <release>
      acquiresleep(&b->lock);
    80002bd0:	01048513          	addi	a0,s1,16
    80002bd4:	338010ef          	jal	80003f0c <acquiresleep>
      return b;
    80002bd8:	a889                	j	80002c2a <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002bda:	0001e497          	auipc	s1,0x1e
    80002bde:	8c64b483          	ld	s1,-1850(s1) # 800204a0 <bcache+0x82b0>
    80002be2:	0001e797          	auipc	a5,0x1e
    80002be6:	87678793          	addi	a5,a5,-1930 # 80020458 <bcache+0x8268>
    80002bea:	00f48863          	beq	s1,a5,80002bfa <bread+0x84>
    80002bee:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002bf0:	40bc                	lw	a5,64(s1)
    80002bf2:	cb91                	beqz	a5,80002c06 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002bf4:	64a4                	ld	s1,72(s1)
    80002bf6:	fee49de3          	bne	s1,a4,80002bf0 <bread+0x7a>
  panic("bget: no buffers");
    80002bfa:	00004517          	auipc	a0,0x4
    80002bfe:	7a650513          	addi	a0,a0,1958 # 800073a0 <etext+0x3a0>
    80002c02:	c17fd0ef          	jal	80000818 <panic>
      b->dev = dev;
    80002c06:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c0a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c0e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c12:	4785                	li	a5,1
    80002c14:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c16:	00015517          	auipc	a0,0x15
    80002c1a:	5da50513          	addi	a0,a0,1498 # 800181f0 <bcache>
    80002c1e:	876fe0ef          	jal	80000c94 <release>
      acquiresleep(&b->lock);
    80002c22:	01048513          	addi	a0,s1,16
    80002c26:	2e6010ef          	jal	80003f0c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002c2a:	409c                	lw	a5,0(s1)
    80002c2c:	cb89                	beqz	a5,80002c3e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c2e:	8526                	mv	a0,s1
    80002c30:	70a2                	ld	ra,40(sp)
    80002c32:	7402                	ld	s0,32(sp)
    80002c34:	64e2                	ld	s1,24(sp)
    80002c36:	6942                	ld	s2,16(sp)
    80002c38:	69a2                	ld	s3,8(sp)
    80002c3a:	6145                	addi	sp,sp,48
    80002c3c:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c3e:	4581                	li	a1,0
    80002c40:	8526                	mv	a0,s1
    80002c42:	34f020ef          	jal	80005790 <virtio_disk_rw>
    b->valid = 1;
    80002c46:	4785                	li	a5,1
    80002c48:	c09c                	sw	a5,0(s1)
  return b;
    80002c4a:	b7d5                	j	80002c2e <bread+0xb8>

0000000080002c4c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c4c:	1101                	addi	sp,sp,-32
    80002c4e:	ec06                	sd	ra,24(sp)
    80002c50:	e822                	sd	s0,16(sp)
    80002c52:	e426                	sd	s1,8(sp)
    80002c54:	1000                	addi	s0,sp,32
    80002c56:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002c58:	0541                	addi	a0,a0,16
    80002c5a:	330010ef          	jal	80003f8a <holdingsleep>
    80002c5e:	c911                	beqz	a0,80002c72 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c60:	4585                	li	a1,1
    80002c62:	8526                	mv	a0,s1
    80002c64:	32d020ef          	jal	80005790 <virtio_disk_rw>
}
    80002c68:	60e2                	ld	ra,24(sp)
    80002c6a:	6442                	ld	s0,16(sp)
    80002c6c:	64a2                	ld	s1,8(sp)
    80002c6e:	6105                	addi	sp,sp,32
    80002c70:	8082                	ret
    panic("bwrite");
    80002c72:	00004517          	auipc	a0,0x4
    80002c76:	74650513          	addi	a0,a0,1862 # 800073b8 <etext+0x3b8>
    80002c7a:	b9ffd0ef          	jal	80000818 <panic>

0000000080002c7e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c7e:	1101                	addi	sp,sp,-32
    80002c80:	ec06                	sd	ra,24(sp)
    80002c82:	e822                	sd	s0,16(sp)
    80002c84:	e426                	sd	s1,8(sp)
    80002c86:	e04a                	sd	s2,0(sp)
    80002c88:	1000                	addi	s0,sp,32
    80002c8a:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002c8c:	01050913          	addi	s2,a0,16
    80002c90:	854a                	mv	a0,s2
    80002c92:	2f8010ef          	jal	80003f8a <holdingsleep>
    80002c96:	c125                	beqz	a0,80002cf6 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002c98:	854a                	mv	a0,s2
    80002c9a:	2b8010ef          	jal	80003f52 <releasesleep>

  acquire(&bcache.lock);
    80002c9e:	00015517          	auipc	a0,0x15
    80002ca2:	55250513          	addi	a0,a0,1362 # 800181f0 <bcache>
    80002ca6:	f5ffd0ef          	jal	80000c04 <acquire>
  b->refcnt--;
    80002caa:	40bc                	lw	a5,64(s1)
    80002cac:	37fd                	addiw	a5,a5,-1
    80002cae:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cb0:	e79d                	bnez	a5,80002cde <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cb2:	68b8                	ld	a4,80(s1)
    80002cb4:	64bc                	ld	a5,72(s1)
    80002cb6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cb8:	68b8                	ld	a4,80(s1)
    80002cba:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002cbc:	0001d797          	auipc	a5,0x1d
    80002cc0:	53478793          	addi	a5,a5,1332 # 800201f0 <bcache+0x8000>
    80002cc4:	2b87b703          	ld	a4,696(a5)
    80002cc8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002cca:	0001d717          	auipc	a4,0x1d
    80002cce:	78e70713          	addi	a4,a4,1934 # 80020458 <bcache+0x8268>
    80002cd2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cd4:	2b87b703          	ld	a4,696(a5)
    80002cd8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002cda:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002cde:	00015517          	auipc	a0,0x15
    80002ce2:	51250513          	addi	a0,a0,1298 # 800181f0 <bcache>
    80002ce6:	faffd0ef          	jal	80000c94 <release>
}
    80002cea:	60e2                	ld	ra,24(sp)
    80002cec:	6442                	ld	s0,16(sp)
    80002cee:	64a2                	ld	s1,8(sp)
    80002cf0:	6902                	ld	s2,0(sp)
    80002cf2:	6105                	addi	sp,sp,32
    80002cf4:	8082                	ret
    panic("brelse");
    80002cf6:	00004517          	auipc	a0,0x4
    80002cfa:	6ca50513          	addi	a0,a0,1738 # 800073c0 <etext+0x3c0>
    80002cfe:	b1bfd0ef          	jal	80000818 <panic>

0000000080002d02 <bpin>:

void
bpin(struct buf *b)
{
    80002d02:	1101                	addi	sp,sp,-32
    80002d04:	ec06                	sd	ra,24(sp)
    80002d06:	e822                	sd	s0,16(sp)
    80002d08:	e426                	sd	s1,8(sp)
    80002d0a:	1000                	addi	s0,sp,32
    80002d0c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d0e:	00015517          	auipc	a0,0x15
    80002d12:	4e250513          	addi	a0,a0,1250 # 800181f0 <bcache>
    80002d16:	eeffd0ef          	jal	80000c04 <acquire>
  b->refcnt++;
    80002d1a:	40bc                	lw	a5,64(s1)
    80002d1c:	2785                	addiw	a5,a5,1
    80002d1e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d20:	00015517          	auipc	a0,0x15
    80002d24:	4d050513          	addi	a0,a0,1232 # 800181f0 <bcache>
    80002d28:	f6dfd0ef          	jal	80000c94 <release>
}
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	64a2                	ld	s1,8(sp)
    80002d32:	6105                	addi	sp,sp,32
    80002d34:	8082                	ret

0000000080002d36 <bunpin>:

void
bunpin(struct buf *b)
{
    80002d36:	1101                	addi	sp,sp,-32
    80002d38:	ec06                	sd	ra,24(sp)
    80002d3a:	e822                	sd	s0,16(sp)
    80002d3c:	e426                	sd	s1,8(sp)
    80002d3e:	1000                	addi	s0,sp,32
    80002d40:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d42:	00015517          	auipc	a0,0x15
    80002d46:	4ae50513          	addi	a0,a0,1198 # 800181f0 <bcache>
    80002d4a:	ebbfd0ef          	jal	80000c04 <acquire>
  b->refcnt--;
    80002d4e:	40bc                	lw	a5,64(s1)
    80002d50:	37fd                	addiw	a5,a5,-1
    80002d52:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d54:	00015517          	auipc	a0,0x15
    80002d58:	49c50513          	addi	a0,a0,1180 # 800181f0 <bcache>
    80002d5c:	f39fd0ef          	jal	80000c94 <release>
}
    80002d60:	60e2                	ld	ra,24(sp)
    80002d62:	6442                	ld	s0,16(sp)
    80002d64:	64a2                	ld	s1,8(sp)
    80002d66:	6105                	addi	sp,sp,32
    80002d68:	8082                	ret

0000000080002d6a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	e04a                	sd	s2,0(sp)
    80002d74:	1000                	addi	s0,sp,32
    80002d76:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d78:	00d5d79b          	srliw	a5,a1,0xd
    80002d7c:	0001e597          	auipc	a1,0x1e
    80002d80:	b505a583          	lw	a1,-1200(a1) # 800208cc <sb+0x1c>
    80002d84:	9dbd                	addw	a1,a1,a5
    80002d86:	df1ff0ef          	jal	80002b76 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d8a:	0074f713          	andi	a4,s1,7
    80002d8e:	4785                	li	a5,1
    80002d90:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002d94:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002d96:	90d9                	srli	s1,s1,0x36
    80002d98:	00950733          	add	a4,a0,s1
    80002d9c:	05874703          	lbu	a4,88(a4)
    80002da0:	00e7f6b3          	and	a3,a5,a4
    80002da4:	c29d                	beqz	a3,80002dca <bfree+0x60>
    80002da6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002da8:	94aa                	add	s1,s1,a0
    80002daa:	fff7c793          	not	a5,a5
    80002dae:	8f7d                	and	a4,a4,a5
    80002db0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002db4:	7f9000ef          	jal	80003dac <log_write>
  brelse(bp);
    80002db8:	854a                	mv	a0,s2
    80002dba:	ec5ff0ef          	jal	80002c7e <brelse>
}
    80002dbe:	60e2                	ld	ra,24(sp)
    80002dc0:	6442                	ld	s0,16(sp)
    80002dc2:	64a2                	ld	s1,8(sp)
    80002dc4:	6902                	ld	s2,0(sp)
    80002dc6:	6105                	addi	sp,sp,32
    80002dc8:	8082                	ret
    panic("freeing free block");
    80002dca:	00004517          	auipc	a0,0x4
    80002dce:	5fe50513          	addi	a0,a0,1534 # 800073c8 <etext+0x3c8>
    80002dd2:	a47fd0ef          	jal	80000818 <panic>

0000000080002dd6 <balloc>:
{
    80002dd6:	715d                	addi	sp,sp,-80
    80002dd8:	e486                	sd	ra,72(sp)
    80002dda:	e0a2                	sd	s0,64(sp)
    80002ddc:	fc26                	sd	s1,56(sp)
    80002dde:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002de0:	0001e797          	auipc	a5,0x1e
    80002de4:	ad47a783          	lw	a5,-1324(a5) # 800208b4 <sb+0x4>
    80002de8:	0e078263          	beqz	a5,80002ecc <balloc+0xf6>
    80002dec:	f84a                	sd	s2,48(sp)
    80002dee:	f44e                	sd	s3,40(sp)
    80002df0:	f052                	sd	s4,32(sp)
    80002df2:	ec56                	sd	s5,24(sp)
    80002df4:	e85a                	sd	s6,16(sp)
    80002df6:	e45e                	sd	s7,8(sp)
    80002df8:	e062                	sd	s8,0(sp)
    80002dfa:	8baa                	mv	s7,a0
    80002dfc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002dfe:	0001eb17          	auipc	s6,0x1e
    80002e02:	ab2b0b13          	addi	s6,s6,-1358 # 800208b0 <sb>
      m = 1 << (bi % 8);
    80002e06:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e08:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002e0a:	6c09                	lui	s8,0x2
    80002e0c:	a09d                	j	80002e72 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002e0e:	97ca                	add	a5,a5,s2
    80002e10:	8e55                	or	a2,a2,a3
    80002e12:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e16:	854a                	mv	a0,s2
    80002e18:	795000ef          	jal	80003dac <log_write>
        brelse(bp);
    80002e1c:	854a                	mv	a0,s2
    80002e1e:	e61ff0ef          	jal	80002c7e <brelse>
  bp = bread(dev, bno);
    80002e22:	85a6                	mv	a1,s1
    80002e24:	855e                	mv	a0,s7
    80002e26:	d51ff0ef          	jal	80002b76 <bread>
    80002e2a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e2c:	40000613          	li	a2,1024
    80002e30:	4581                	li	a1,0
    80002e32:	05850513          	addi	a0,a0,88
    80002e36:	e97fd0ef          	jal	80000ccc <memset>
  log_write(bp);
    80002e3a:	854a                	mv	a0,s2
    80002e3c:	771000ef          	jal	80003dac <log_write>
  brelse(bp);
    80002e40:	854a                	mv	a0,s2
    80002e42:	e3dff0ef          	jal	80002c7e <brelse>
}
    80002e46:	7942                	ld	s2,48(sp)
    80002e48:	79a2                	ld	s3,40(sp)
    80002e4a:	7a02                	ld	s4,32(sp)
    80002e4c:	6ae2                	ld	s5,24(sp)
    80002e4e:	6b42                	ld	s6,16(sp)
    80002e50:	6ba2                	ld	s7,8(sp)
    80002e52:	6c02                	ld	s8,0(sp)
}
    80002e54:	8526                	mv	a0,s1
    80002e56:	60a6                	ld	ra,72(sp)
    80002e58:	6406                	ld	s0,64(sp)
    80002e5a:	74e2                	ld	s1,56(sp)
    80002e5c:	6161                	addi	sp,sp,80
    80002e5e:	8082                	ret
    brelse(bp);
    80002e60:	854a                	mv	a0,s2
    80002e62:	e1dff0ef          	jal	80002c7e <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002e66:	015c0abb          	addw	s5,s8,s5
    80002e6a:	004b2783          	lw	a5,4(s6)
    80002e6e:	04faf863          	bgeu	s5,a5,80002ebe <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002e72:	40dad59b          	sraiw	a1,s5,0xd
    80002e76:	01cb2783          	lw	a5,28(s6)
    80002e7a:	9dbd                	addw	a1,a1,a5
    80002e7c:	855e                	mv	a0,s7
    80002e7e:	cf9ff0ef          	jal	80002b76 <bread>
    80002e82:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e84:	004b2503          	lw	a0,4(s6)
    80002e88:	84d6                	mv	s1,s5
    80002e8a:	4701                	li	a4,0
    80002e8c:	fca4fae3          	bgeu	s1,a0,80002e60 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002e90:	00777693          	andi	a3,a4,7
    80002e94:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002e98:	41f7579b          	sraiw	a5,a4,0x1f
    80002e9c:	01d7d79b          	srliw	a5,a5,0x1d
    80002ea0:	9fb9                	addw	a5,a5,a4
    80002ea2:	4037d79b          	sraiw	a5,a5,0x3
    80002ea6:	00f90633          	add	a2,s2,a5
    80002eaa:	05864603          	lbu	a2,88(a2)
    80002eae:	00c6f5b3          	and	a1,a3,a2
    80002eb2:	ddb1                	beqz	a1,80002e0e <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002eb4:	2705                	addiw	a4,a4,1
    80002eb6:	2485                	addiw	s1,s1,1
    80002eb8:	fd471ae3          	bne	a4,s4,80002e8c <balloc+0xb6>
    80002ebc:	b755                	j	80002e60 <balloc+0x8a>
    80002ebe:	7942                	ld	s2,48(sp)
    80002ec0:	79a2                	ld	s3,40(sp)
    80002ec2:	7a02                	ld	s4,32(sp)
    80002ec4:	6ae2                	ld	s5,24(sp)
    80002ec6:	6b42                	ld	s6,16(sp)
    80002ec8:	6ba2                	ld	s7,8(sp)
    80002eca:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002ecc:	00004517          	auipc	a0,0x4
    80002ed0:	51450513          	addi	a0,a0,1300 # 800073e0 <etext+0x3e0>
    80002ed4:	e1afd0ef          	jal	800004ee <printk>
  return 0;
    80002ed8:	4481                	li	s1,0
    80002eda:	bfad                	j	80002e54 <balloc+0x7e>

0000000080002edc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002edc:	7179                	addi	sp,sp,-48
    80002ede:	f406                	sd	ra,40(sp)
    80002ee0:	f022                	sd	s0,32(sp)
    80002ee2:	ec26                	sd	s1,24(sp)
    80002ee4:	e84a                	sd	s2,16(sp)
    80002ee6:	e44e                	sd	s3,8(sp)
    80002ee8:	1800                	addi	s0,sp,48
    80002eea:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002eec:	47ad                	li	a5,11
    80002eee:	02b7e363          	bltu	a5,a1,80002f14 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80002ef2:	02059793          	slli	a5,a1,0x20
    80002ef6:	01e7d593          	srli	a1,a5,0x1e
    80002efa:	00b509b3          	add	s3,a0,a1
    80002efe:	0509a483          	lw	s1,80(s3)
    80002f02:	e0b5                	bnez	s1,80002f66 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f04:	4108                	lw	a0,0(a0)
    80002f06:	ed1ff0ef          	jal	80002dd6 <balloc>
    80002f0a:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f0c:	cd29                	beqz	a0,80002f66 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f0e:	04a9a823          	sw	a0,80(s3)
    80002f12:	a891                	j	80002f66 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f14:	ff45879b          	addiw	a5,a1,-12
    80002f18:	873e                	mv	a4,a5
    80002f1a:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80002f1c:	0ff00793          	li	a5,255
    80002f20:	06e7e763          	bltu	a5,a4,80002f8e <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002f24:	08052483          	lw	s1,128(a0)
    80002f28:	e891                	bnez	s1,80002f3c <bmap+0x60>
      addr = balloc(ip->dev);
    80002f2a:	4108                	lw	a0,0(a0)
    80002f2c:	eabff0ef          	jal	80002dd6 <balloc>
    80002f30:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f32:	c915                	beqz	a0,80002f66 <bmap+0x8a>
    80002f34:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f36:	08a92023          	sw	a0,128(s2)
    80002f3a:	a011                	j	80002f3e <bmap+0x62>
    80002f3c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f3e:	85a6                	mv	a1,s1
    80002f40:	00092503          	lw	a0,0(s2)
    80002f44:	c33ff0ef          	jal	80002b76 <bread>
    80002f48:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002f4a:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002f4e:	02099713          	slli	a4,s3,0x20
    80002f52:	01e75593          	srli	a1,a4,0x1e
    80002f56:	97ae                	add	a5,a5,a1
    80002f58:	89be                	mv	s3,a5
    80002f5a:	4384                	lw	s1,0(a5)
    80002f5c:	cc89                	beqz	s1,80002f76 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f5e:	8552                	mv	a0,s4
    80002f60:	d1fff0ef          	jal	80002c7e <brelse>
    return addr;
    80002f64:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f66:	8526                	mv	a0,s1
    80002f68:	70a2                	ld	ra,40(sp)
    80002f6a:	7402                	ld	s0,32(sp)
    80002f6c:	64e2                	ld	s1,24(sp)
    80002f6e:	6942                	ld	s2,16(sp)
    80002f70:	69a2                	ld	s3,8(sp)
    80002f72:	6145                	addi	sp,sp,48
    80002f74:	8082                	ret
      addr = balloc(ip->dev);
    80002f76:	00092503          	lw	a0,0(s2)
    80002f7a:	e5dff0ef          	jal	80002dd6 <balloc>
    80002f7e:	84aa                	mv	s1,a0
      if (addr) {
    80002f80:	dd79                	beqz	a0,80002f5e <bmap+0x82>
        a[bn] = addr;
    80002f82:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002f86:	8552                	mv	a0,s4
    80002f88:	625000ef          	jal	80003dac <log_write>
    80002f8c:	bfc9                	j	80002f5e <bmap+0x82>
    80002f8e:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f90:	00004517          	auipc	a0,0x4
    80002f94:	46850513          	addi	a0,a0,1128 # 800073f8 <etext+0x3f8>
    80002f98:	881fd0ef          	jal	80000818 <panic>

0000000080002f9c <iget>:
{
    80002f9c:	7179                	addi	sp,sp,-48
    80002f9e:	f406                	sd	ra,40(sp)
    80002fa0:	f022                	sd	s0,32(sp)
    80002fa2:	ec26                	sd	s1,24(sp)
    80002fa4:	e84a                	sd	s2,16(sp)
    80002fa6:	e44e                	sd	s3,8(sp)
    80002fa8:	e052                	sd	s4,0(sp)
    80002faa:	1800                	addi	s0,sp,48
    80002fac:	892a                	mv	s2,a0
    80002fae:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002fb0:	0001e517          	auipc	a0,0x1e
    80002fb4:	92050513          	addi	a0,a0,-1760 # 800208d0 <itable>
    80002fb8:	c4dfd0ef          	jal	80000c04 <acquire>
  empty = 0;
    80002fbc:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002fbe:	0001e497          	auipc	s1,0x1e
    80002fc2:	92a48493          	addi	s1,s1,-1750 # 800208e8 <itable+0x18>
    80002fc6:	0001f697          	auipc	a3,0x1f
    80002fca:	3b268693          	addi	a3,a3,946 # 80022378 <log>
    80002fce:	a809                	j	80002fe0 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80002fd0:	e781                	bnez	a5,80002fd8 <iget+0x3c>
    80002fd2:	00099363          	bnez	s3,80002fd8 <iget+0x3c>
      empty = ip;
    80002fd6:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002fd8:	08848493          	addi	s1,s1,136
    80002fdc:	02d48563          	beq	s1,a3,80003006 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80002fe0:	449c                	lw	a5,8(s1)
    80002fe2:	fef057e3          	blez	a5,80002fd0 <iget+0x34>
    80002fe6:	4098                	lw	a4,0(s1)
    80002fe8:	ff2718e3          	bne	a4,s2,80002fd8 <iget+0x3c>
    80002fec:	40d8                	lw	a4,4(s1)
    80002fee:	ff4715e3          	bne	a4,s4,80002fd8 <iget+0x3c>
      ip->ref++;
    80002ff2:	2785                	addiw	a5,a5,1
    80002ff4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002ff6:	0001e517          	auipc	a0,0x1e
    80002ffa:	8da50513          	addi	a0,a0,-1830 # 800208d0 <itable>
    80002ffe:	c97fd0ef          	jal	80000c94 <release>
      return ip;
    80003002:	89a6                	mv	s3,s1
    80003004:	a015                	j	80003028 <iget+0x8c>
  if (empty == 0)
    80003006:	02098a63          	beqz	s3,8000303a <iget+0x9e>
  ip->dev = dev;
    8000300a:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000300e:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003012:	4785                	li	a5,1
    80003014:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003018:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000301c:	0001e517          	auipc	a0,0x1e
    80003020:	8b450513          	addi	a0,a0,-1868 # 800208d0 <itable>
    80003024:	c71fd0ef          	jal	80000c94 <release>
}
    80003028:	854e                	mv	a0,s3
    8000302a:	70a2                	ld	ra,40(sp)
    8000302c:	7402                	ld	s0,32(sp)
    8000302e:	64e2                	ld	s1,24(sp)
    80003030:	6942                	ld	s2,16(sp)
    80003032:	69a2                	ld	s3,8(sp)
    80003034:	6a02                	ld	s4,0(sp)
    80003036:	6145                	addi	sp,sp,48
    80003038:	8082                	ret
    panic("iget: no inodes");
    8000303a:	00004517          	auipc	a0,0x4
    8000303e:	3d650513          	addi	a0,a0,982 # 80007410 <etext+0x410>
    80003042:	fd6fd0ef          	jal	80000818 <panic>

0000000080003046 <iinit>:
{
    80003046:	7179                	addi	sp,sp,-48
    80003048:	f406                	sd	ra,40(sp)
    8000304a:	f022                	sd	s0,32(sp)
    8000304c:	ec26                	sd	s1,24(sp)
    8000304e:	e84a                	sd	s2,16(sp)
    80003050:	e44e                	sd	s3,8(sp)
    80003052:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003054:	00004597          	auipc	a1,0x4
    80003058:	3cc58593          	addi	a1,a1,972 # 80007420 <etext+0x420>
    8000305c:	0001e517          	auipc	a0,0x1e
    80003060:	87450513          	addi	a0,a0,-1932 # 800208d0 <itable>
    80003064:	b17fd0ef          	jal	80000b7a <initlock>
  for (i = 0; i < NINODE; i++) {
    80003068:	0001e497          	auipc	s1,0x1e
    8000306c:	89048493          	addi	s1,s1,-1904 # 800208f8 <itable+0x28>
    80003070:	0001f997          	auipc	s3,0x1f
    80003074:	31898993          	addi	s3,s3,792 # 80022388 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003078:	00004917          	auipc	s2,0x4
    8000307c:	3b090913          	addi	s2,s2,944 # 80007428 <etext+0x428>
    80003080:	85ca                	mv	a1,s2
    80003082:	8526                	mv	a0,s1
    80003084:	653000ef          	jal	80003ed6 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003088:	08848493          	addi	s1,s1,136
    8000308c:	ff349ae3          	bne	s1,s3,80003080 <iinit+0x3a>
}
    80003090:	70a2                	ld	ra,40(sp)
    80003092:	7402                	ld	s0,32(sp)
    80003094:	64e2                	ld	s1,24(sp)
    80003096:	6942                	ld	s2,16(sp)
    80003098:	69a2                	ld	s3,8(sp)
    8000309a:	6145                	addi	sp,sp,48
    8000309c:	8082                	ret

000000008000309e <ialloc>:
{
    8000309e:	7139                	addi	sp,sp,-64
    800030a0:	fc06                	sd	ra,56(sp)
    800030a2:	f822                	sd	s0,48(sp)
    800030a4:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800030a6:	0001e717          	auipc	a4,0x1e
    800030aa:	81672703          	lw	a4,-2026(a4) # 800208bc <sb+0xc>
    800030ae:	4785                	li	a5,1
    800030b0:	06e7f063          	bgeu	a5,a4,80003110 <ialloc+0x72>
    800030b4:	f426                	sd	s1,40(sp)
    800030b6:	f04a                	sd	s2,32(sp)
    800030b8:	ec4e                	sd	s3,24(sp)
    800030ba:	e852                	sd	s4,16(sp)
    800030bc:	e456                	sd	s5,8(sp)
    800030be:	e05a                	sd	s6,0(sp)
    800030c0:	8aaa                	mv	s5,a0
    800030c2:	8b2e                	mv	s6,a1
    800030c4:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800030c6:	0001da17          	auipc	s4,0x1d
    800030ca:	7eaa0a13          	addi	s4,s4,2026 # 800208b0 <sb>
    800030ce:	00495593          	srli	a1,s2,0x4
    800030d2:	018a2783          	lw	a5,24(s4)
    800030d6:	9dbd                	addw	a1,a1,a5
    800030d8:	8556                	mv	a0,s5
    800030da:	a9dff0ef          	jal	80002b76 <bread>
    800030de:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800030e0:	05850993          	addi	s3,a0,88
    800030e4:	00f97793          	andi	a5,s2,15
    800030e8:	079a                	slli	a5,a5,0x6
    800030ea:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800030ec:	00099783          	lh	a5,0(s3)
    800030f0:	cb9d                	beqz	a5,80003126 <ialloc+0x88>
    brelse(bp);
    800030f2:	b8dff0ef          	jal	80002c7e <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800030f6:	0905                	addi	s2,s2,1
    800030f8:	00ca2703          	lw	a4,12(s4)
    800030fc:	0009079b          	sext.w	a5,s2
    80003100:	fce7e7e3          	bltu	a5,a4,800030ce <ialloc+0x30>
    80003104:	74a2                	ld	s1,40(sp)
    80003106:	7902                	ld	s2,32(sp)
    80003108:	69e2                	ld	s3,24(sp)
    8000310a:	6a42                	ld	s4,16(sp)
    8000310c:	6aa2                	ld	s5,8(sp)
    8000310e:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003110:	00004517          	auipc	a0,0x4
    80003114:	32050513          	addi	a0,a0,800 # 80007430 <etext+0x430>
    80003118:	bd6fd0ef          	jal	800004ee <printk>
  return 0;
    8000311c:	4501                	li	a0,0
}
    8000311e:	70e2                	ld	ra,56(sp)
    80003120:	7442                	ld	s0,48(sp)
    80003122:	6121                	addi	sp,sp,64
    80003124:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003126:	04000613          	li	a2,64
    8000312a:	4581                	li	a1,0
    8000312c:	854e                	mv	a0,s3
    8000312e:	b9ffd0ef          	jal	80000ccc <memset>
      dip->type = type;
    80003132:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003136:	8526                	mv	a0,s1
    80003138:	475000ef          	jal	80003dac <log_write>
      brelse(bp);
    8000313c:	8526                	mv	a0,s1
    8000313e:	b41ff0ef          	jal	80002c7e <brelse>
      return iget(dev, inum);
    80003142:	0009059b          	sext.w	a1,s2
    80003146:	8556                	mv	a0,s5
    80003148:	e55ff0ef          	jal	80002f9c <iget>
    8000314c:	74a2                	ld	s1,40(sp)
    8000314e:	7902                	ld	s2,32(sp)
    80003150:	69e2                	ld	s3,24(sp)
    80003152:	6a42                	ld	s4,16(sp)
    80003154:	6aa2                	ld	s5,8(sp)
    80003156:	6b02                	ld	s6,0(sp)
    80003158:	b7d9                	j	8000311e <ialloc+0x80>

000000008000315a <iupdate>:
{
    8000315a:	1101                	addi	sp,sp,-32
    8000315c:	ec06                	sd	ra,24(sp)
    8000315e:	e822                	sd	s0,16(sp)
    80003160:	e426                	sd	s1,8(sp)
    80003162:	e04a                	sd	s2,0(sp)
    80003164:	1000                	addi	s0,sp,32
    80003166:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003168:	415c                	lw	a5,4(a0)
    8000316a:	0047d79b          	srliw	a5,a5,0x4
    8000316e:	0001d597          	auipc	a1,0x1d
    80003172:	75a5a583          	lw	a1,1882(a1) # 800208c8 <sb+0x18>
    80003176:	9dbd                	addw	a1,a1,a5
    80003178:	4108                	lw	a0,0(a0)
    8000317a:	9fdff0ef          	jal	80002b76 <bread>
    8000317e:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003180:	05850793          	addi	a5,a0,88
    80003184:	40d8                	lw	a4,4(s1)
    80003186:	8b3d                	andi	a4,a4,15
    80003188:	071a                	slli	a4,a4,0x6
    8000318a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000318c:	04449703          	lh	a4,68(s1)
    80003190:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003194:	04649703          	lh	a4,70(s1)
    80003198:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000319c:	04849703          	lh	a4,72(s1)
    800031a0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031a4:	04a49703          	lh	a4,74(s1)
    800031a8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031ac:	44f8                	lw	a4,76(s1)
    800031ae:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031b0:	03400613          	li	a2,52
    800031b4:	05048593          	addi	a1,s1,80
    800031b8:	00c78513          	addi	a0,a5,12
    800031bc:	b71fd0ef          	jal	80000d2c <memmove>
  log_write(bp);
    800031c0:	854a                	mv	a0,s2
    800031c2:	3eb000ef          	jal	80003dac <log_write>
  brelse(bp);
    800031c6:	854a                	mv	a0,s2
    800031c8:	ab7ff0ef          	jal	80002c7e <brelse>
}
    800031cc:	60e2                	ld	ra,24(sp)
    800031ce:	6442                	ld	s0,16(sp)
    800031d0:	64a2                	ld	s1,8(sp)
    800031d2:	6902                	ld	s2,0(sp)
    800031d4:	6105                	addi	sp,sp,32
    800031d6:	8082                	ret

00000000800031d8 <idup>:
{
    800031d8:	1101                	addi	sp,sp,-32
    800031da:	ec06                	sd	ra,24(sp)
    800031dc:	e822                	sd	s0,16(sp)
    800031de:	e426                	sd	s1,8(sp)
    800031e0:	1000                	addi	s0,sp,32
    800031e2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031e4:	0001d517          	auipc	a0,0x1d
    800031e8:	6ec50513          	addi	a0,a0,1772 # 800208d0 <itable>
    800031ec:	a19fd0ef          	jal	80000c04 <acquire>
  ip->ref++;
    800031f0:	449c                	lw	a5,8(s1)
    800031f2:	2785                	addiw	a5,a5,1
    800031f4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031f6:	0001d517          	auipc	a0,0x1d
    800031fa:	6da50513          	addi	a0,a0,1754 # 800208d0 <itable>
    800031fe:	a97fd0ef          	jal	80000c94 <release>
}
    80003202:	8526                	mv	a0,s1
    80003204:	60e2                	ld	ra,24(sp)
    80003206:	6442                	ld	s0,16(sp)
    80003208:	64a2                	ld	s1,8(sp)
    8000320a:	6105                	addi	sp,sp,32
    8000320c:	8082                	ret

000000008000320e <ilock>:
{
    8000320e:	1101                	addi	sp,sp,-32
    80003210:	ec06                	sd	ra,24(sp)
    80003212:	e822                	sd	s0,16(sp)
    80003214:	e426                	sd	s1,8(sp)
    80003216:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003218:	cd19                	beqz	a0,80003236 <ilock+0x28>
    8000321a:	84aa                	mv	s1,a0
    8000321c:	451c                	lw	a5,8(a0)
    8000321e:	00f05c63          	blez	a5,80003236 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003222:	0541                	addi	a0,a0,16
    80003224:	4e9000ef          	jal	80003f0c <acquiresleep>
  if (ip->valid == 0) {
    80003228:	40bc                	lw	a5,64(s1)
    8000322a:	cf89                	beqz	a5,80003244 <ilock+0x36>
}
    8000322c:	60e2                	ld	ra,24(sp)
    8000322e:	6442                	ld	s0,16(sp)
    80003230:	64a2                	ld	s1,8(sp)
    80003232:	6105                	addi	sp,sp,32
    80003234:	8082                	ret
    80003236:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003238:	00004517          	auipc	a0,0x4
    8000323c:	21050513          	addi	a0,a0,528 # 80007448 <etext+0x448>
    80003240:	dd8fd0ef          	jal	80000818 <panic>
    80003244:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003246:	40dc                	lw	a5,4(s1)
    80003248:	0047d79b          	srliw	a5,a5,0x4
    8000324c:	0001d597          	auipc	a1,0x1d
    80003250:	67c5a583          	lw	a1,1660(a1) # 800208c8 <sb+0x18>
    80003254:	9dbd                	addw	a1,a1,a5
    80003256:	4088                	lw	a0,0(s1)
    80003258:	91fff0ef          	jal	80002b76 <bread>
    8000325c:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000325e:	05850593          	addi	a1,a0,88
    80003262:	40dc                	lw	a5,4(s1)
    80003264:	8bbd                	andi	a5,a5,15
    80003266:	079a                	slli	a5,a5,0x6
    80003268:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000326a:	00059783          	lh	a5,0(a1)
    8000326e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003272:	00259783          	lh	a5,2(a1)
    80003276:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000327a:	00459783          	lh	a5,4(a1)
    8000327e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003282:	00659783          	lh	a5,6(a1)
    80003286:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000328a:	459c                	lw	a5,8(a1)
    8000328c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000328e:	03400613          	li	a2,52
    80003292:	05b1                	addi	a1,a1,12
    80003294:	05048513          	addi	a0,s1,80
    80003298:	a95fd0ef          	jal	80000d2c <memmove>
    brelse(bp);
    8000329c:	854a                	mv	a0,s2
    8000329e:	9e1ff0ef          	jal	80002c7e <brelse>
    ip->valid = 1;
    800032a2:	4785                	li	a5,1
    800032a4:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800032a6:	04449783          	lh	a5,68(s1)
    800032aa:	c399                	beqz	a5,800032b0 <ilock+0xa2>
    800032ac:	6902                	ld	s2,0(sp)
    800032ae:	bfbd                	j	8000322c <ilock+0x1e>
      panic("ilock: no type");
    800032b0:	00004517          	auipc	a0,0x4
    800032b4:	1a050513          	addi	a0,a0,416 # 80007450 <etext+0x450>
    800032b8:	d60fd0ef          	jal	80000818 <panic>

00000000800032bc <iunlock>:
{
    800032bc:	1101                	addi	sp,sp,-32
    800032be:	ec06                	sd	ra,24(sp)
    800032c0:	e822                	sd	s0,16(sp)
    800032c2:	e426                	sd	s1,8(sp)
    800032c4:	e04a                	sd	s2,0(sp)
    800032c6:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032c8:	c505                	beqz	a0,800032f0 <iunlock+0x34>
    800032ca:	84aa                	mv	s1,a0
    800032cc:	01050913          	addi	s2,a0,16
    800032d0:	854a                	mv	a0,s2
    800032d2:	4b9000ef          	jal	80003f8a <holdingsleep>
    800032d6:	cd09                	beqz	a0,800032f0 <iunlock+0x34>
    800032d8:	449c                	lw	a5,8(s1)
    800032da:	00f05b63          	blez	a5,800032f0 <iunlock+0x34>
  releasesleep(&ip->lock);
    800032de:	854a                	mv	a0,s2
    800032e0:	473000ef          	jal	80003f52 <releasesleep>
}
    800032e4:	60e2                	ld	ra,24(sp)
    800032e6:	6442                	ld	s0,16(sp)
    800032e8:	64a2                	ld	s1,8(sp)
    800032ea:	6902                	ld	s2,0(sp)
    800032ec:	6105                	addi	sp,sp,32
    800032ee:	8082                	ret
    panic("iunlock");
    800032f0:	00004517          	auipc	a0,0x4
    800032f4:	17050513          	addi	a0,a0,368 # 80007460 <etext+0x460>
    800032f8:	d20fd0ef          	jal	80000818 <panic>

00000000800032fc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032fc:	7179                	addi	sp,sp,-48
    800032fe:	f406                	sd	ra,40(sp)
    80003300:	f022                	sd	s0,32(sp)
    80003302:	ec26                	sd	s1,24(sp)
    80003304:	e84a                	sd	s2,16(sp)
    80003306:	e44e                	sd	s3,8(sp)
    80003308:	1800                	addi	s0,sp,48
    8000330a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    8000330c:	05050493          	addi	s1,a0,80
    80003310:	08050913          	addi	s2,a0,128
    80003314:	a021                	j	8000331c <itrunc+0x20>
    80003316:	0491                	addi	s1,s1,4
    80003318:	01248b63          	beq	s1,s2,8000332e <itrunc+0x32>
    if (ip->addrs[i]) {
    8000331c:	408c                	lw	a1,0(s1)
    8000331e:	dde5                	beqz	a1,80003316 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003320:	0009a503          	lw	a0,0(s3)
    80003324:	a47ff0ef          	jal	80002d6a <bfree>
      ip->addrs[i] = 0;
    80003328:	0004a023          	sw	zero,0(s1)
    8000332c:	b7ed                	j	80003316 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000332e:	0809a583          	lw	a1,128(s3)
    80003332:	ed89                	bnez	a1,8000334c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003334:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003338:	854e                	mv	a0,s3
    8000333a:	e21ff0ef          	jal	8000315a <iupdate>
}
    8000333e:	70a2                	ld	ra,40(sp)
    80003340:	7402                	ld	s0,32(sp)
    80003342:	64e2                	ld	s1,24(sp)
    80003344:	6942                	ld	s2,16(sp)
    80003346:	69a2                	ld	s3,8(sp)
    80003348:	6145                	addi	sp,sp,48
    8000334a:	8082                	ret
    8000334c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000334e:	0009a503          	lw	a0,0(s3)
    80003352:	825ff0ef          	jal	80002b76 <bread>
    80003356:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003358:	05850493          	addi	s1,a0,88
    8000335c:	45850913          	addi	s2,a0,1112
    80003360:	a021                	j	80003368 <itrunc+0x6c>
    80003362:	0491                	addi	s1,s1,4
    80003364:	01248963          	beq	s1,s2,80003376 <itrunc+0x7a>
      if (a[j])
    80003368:	408c                	lw	a1,0(s1)
    8000336a:	dde5                	beqz	a1,80003362 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000336c:	0009a503          	lw	a0,0(s3)
    80003370:	9fbff0ef          	jal	80002d6a <bfree>
    80003374:	b7fd                	j	80003362 <itrunc+0x66>
    brelse(bp);
    80003376:	8552                	mv	a0,s4
    80003378:	907ff0ef          	jal	80002c7e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000337c:	0809a583          	lw	a1,128(s3)
    80003380:	0009a503          	lw	a0,0(s3)
    80003384:	9e7ff0ef          	jal	80002d6a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003388:	0809a023          	sw	zero,128(s3)
    8000338c:	6a02                	ld	s4,0(sp)
    8000338e:	b75d                	j	80003334 <itrunc+0x38>

0000000080003390 <iput>:
{
    80003390:	1101                	addi	sp,sp,-32
    80003392:	ec06                	sd	ra,24(sp)
    80003394:	e822                	sd	s0,16(sp)
    80003396:	e426                	sd	s1,8(sp)
    80003398:	1000                	addi	s0,sp,32
    8000339a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000339c:	0001d517          	auipc	a0,0x1d
    800033a0:	53450513          	addi	a0,a0,1332 # 800208d0 <itable>
    800033a4:	861fd0ef          	jal	80000c04 <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0) {
    800033a8:	4498                	lw	a4,8(s1)
    800033aa:	4785                	li	a5,1
    800033ac:	02f70063          	beq	a4,a5,800033cc <iput+0x3c>
  ip->ref--;
    800033b0:	449c                	lw	a5,8(s1)
    800033b2:	37fd                	addiw	a5,a5,-1
    800033b4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033b6:	0001d517          	auipc	a0,0x1d
    800033ba:	51a50513          	addi	a0,a0,1306 # 800208d0 <itable>
    800033be:	8d7fd0ef          	jal	80000c94 <release>
}
    800033c2:	60e2                	ld	ra,24(sp)
    800033c4:	6442                	ld	s0,16(sp)
    800033c6:	64a2                	ld	s1,8(sp)
    800033c8:	6105                	addi	sp,sp,32
    800033ca:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0) {
    800033cc:	40bc                	lw	a5,64(s1)
    800033ce:	d3ed                	beqz	a5,800033b0 <iput+0x20>
    800033d0:	04a49783          	lh	a5,74(s1)
    800033d4:	fff1                	bnez	a5,800033b0 <iput+0x20>
    800033d6:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800033d8:	01048793          	addi	a5,s1,16
    800033dc:	893e                	mv	s2,a5
    800033de:	853e                	mv	a0,a5
    800033e0:	32d000ef          	jal	80003f0c <acquiresleep>
    release(&itable.lock);
    800033e4:	0001d517          	auipc	a0,0x1d
    800033e8:	4ec50513          	addi	a0,a0,1260 # 800208d0 <itable>
    800033ec:	8a9fd0ef          	jal	80000c94 <release>
    itrunc(ip);
    800033f0:	8526                	mv	a0,s1
    800033f2:	f0bff0ef          	jal	800032fc <itrunc>
    ip->type = 0;
    800033f6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033fa:	8526                	mv	a0,s1
    800033fc:	d5fff0ef          	jal	8000315a <iupdate>
    ip->valid = 0;
    80003400:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003404:	854a                	mv	a0,s2
    80003406:	34d000ef          	jal	80003f52 <releasesleep>
    acquire(&itable.lock);
    8000340a:	0001d517          	auipc	a0,0x1d
    8000340e:	4c650513          	addi	a0,a0,1222 # 800208d0 <itable>
    80003412:	ff2fd0ef          	jal	80000c04 <acquire>
    80003416:	6902                	ld	s2,0(sp)
    80003418:	bf61                	j	800033b0 <iput+0x20>

000000008000341a <iunlockput>:
{
    8000341a:	1101                	addi	sp,sp,-32
    8000341c:	ec06                	sd	ra,24(sp)
    8000341e:	e822                	sd	s0,16(sp)
    80003420:	e426                	sd	s1,8(sp)
    80003422:	1000                	addi	s0,sp,32
    80003424:	84aa                	mv	s1,a0
  iunlock(ip);
    80003426:	e97ff0ef          	jal	800032bc <iunlock>
  iput(ip);
    8000342a:	8526                	mv	a0,s1
    8000342c:	f65ff0ef          	jal	80003390 <iput>
}
    80003430:	60e2                	ld	ra,24(sp)
    80003432:	6442                	ld	s0,16(sp)
    80003434:	64a2                	ld	s1,8(sp)
    80003436:	6105                	addi	sp,sp,32
    80003438:	8082                	ret

000000008000343a <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000343a:	0001d717          	auipc	a4,0x1d
    8000343e:	48272703          	lw	a4,1154(a4) # 800208bc <sb+0xc>
    80003442:	4785                	li	a5,1
    80003444:	0ae7fe63          	bgeu	a5,a4,80003500 <ireclaim+0xc6>
{
    80003448:	7139                	addi	sp,sp,-64
    8000344a:	fc06                	sd	ra,56(sp)
    8000344c:	f822                	sd	s0,48(sp)
    8000344e:	f426                	sd	s1,40(sp)
    80003450:	f04a                	sd	s2,32(sp)
    80003452:	ec4e                	sd	s3,24(sp)
    80003454:	e852                	sd	s4,16(sp)
    80003456:	e456                	sd	s5,8(sp)
    80003458:	e05a                	sd	s6,0(sp)
    8000345a:	0080                	addi	s0,sp,64
    8000345c:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000345e:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003460:	0001da17          	auipc	s4,0x1d
    80003464:	450a0a13          	addi	s4,s4,1104 # 800208b0 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003468:	00004b17          	auipc	s6,0x4
    8000346c:	000b0b13          	mv	s6,s6
    80003470:	a099                	j	800034b6 <ireclaim+0x7c>
    80003472:	85ce                	mv	a1,s3
    80003474:	855a                	mv	a0,s6
    80003476:	878fd0ef          	jal	800004ee <printk>
      ip = iget(dev, inum);
    8000347a:	85ce                	mv	a1,s3
    8000347c:	8556                	mv	a0,s5
    8000347e:	b1fff0ef          	jal	80002f9c <iget>
    80003482:	89aa                	mv	s3,a0
    brelse(bp);
    80003484:	854a                	mv	a0,s2
    80003486:	ff8ff0ef          	jal	80002c7e <brelse>
    if (ip) {
    8000348a:	00098f63          	beqz	s3,800034a8 <ireclaim+0x6e>
      begin_op();
    8000348e:	78c000ef          	jal	80003c1a <begin_op>
      ilock(ip);
    80003492:	854e                	mv	a0,s3
    80003494:	d7bff0ef          	jal	8000320e <ilock>
      iunlock(ip);
    80003498:	854e                	mv	a0,s3
    8000349a:	e23ff0ef          	jal	800032bc <iunlock>
      iput(ip);
    8000349e:	854e                	mv	a0,s3
    800034a0:	ef1ff0ef          	jal	80003390 <iput>
      end_op();
    800034a4:	7e6000ef          	jal	80003c8a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034a8:	0485                	addi	s1,s1,1
    800034aa:	00ca2703          	lw	a4,12(s4)
    800034ae:	0004879b          	sext.w	a5,s1
    800034b2:	02e7fd63          	bgeu	a5,a4,800034ec <ireclaim+0xb2>
    800034b6:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034ba:	0044d593          	srli	a1,s1,0x4
    800034be:	018a2783          	lw	a5,24(s4)
    800034c2:	9dbd                	addw	a1,a1,a5
    800034c4:	8556                	mv	a0,s5
    800034c6:	eb0ff0ef          	jal	80002b76 <bread>
    800034ca:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034cc:	05850793          	addi	a5,a0,88
    800034d0:	00f9f713          	andi	a4,s3,15
    800034d4:	071a                	slli	a4,a4,0x6
    800034d6:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800034d8:	00079703          	lh	a4,0(a5)
    800034dc:	c701                	beqz	a4,800034e4 <ireclaim+0xaa>
    800034de:	00679783          	lh	a5,6(a5)
    800034e2:	dbc1                	beqz	a5,80003472 <ireclaim+0x38>
    brelse(bp);
    800034e4:	854a                	mv	a0,s2
    800034e6:	f98ff0ef          	jal	80002c7e <brelse>
    if (ip) {
    800034ea:	bf7d                	j	800034a8 <ireclaim+0x6e>
}
    800034ec:	70e2                	ld	ra,56(sp)
    800034ee:	7442                	ld	s0,48(sp)
    800034f0:	74a2                	ld	s1,40(sp)
    800034f2:	7902                	ld	s2,32(sp)
    800034f4:	69e2                	ld	s3,24(sp)
    800034f6:	6a42                	ld	s4,16(sp)
    800034f8:	6aa2                	ld	s5,8(sp)
    800034fa:	6b02                	ld	s6,0(sp)
    800034fc:	6121                	addi	sp,sp,64
    800034fe:	8082                	ret
    80003500:	8082                	ret

0000000080003502 <fsinit>:
{
    80003502:	1101                	addi	sp,sp,-32
    80003504:	ec06                	sd	ra,24(sp)
    80003506:	e822                	sd	s0,16(sp)
    80003508:	e426                	sd	s1,8(sp)
    8000350a:	e04a                	sd	s2,0(sp)
    8000350c:	1000                	addi	s0,sp,32
    8000350e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003510:	4585                	li	a1,1
    80003512:	e64ff0ef          	jal	80002b76 <bread>
    80003516:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003518:	02000613          	li	a2,32
    8000351c:	05850593          	addi	a1,a0,88
    80003520:	0001d517          	auipc	a0,0x1d
    80003524:	39050513          	addi	a0,a0,912 # 800208b0 <sb>
    80003528:	805fd0ef          	jal	80000d2c <memmove>
  brelse(bp);
    8000352c:	8526                	mv	a0,s1
    8000352e:	f50ff0ef          	jal	80002c7e <brelse>
  if (sb.magic != FSMAGIC)
    80003532:	0001d717          	auipc	a4,0x1d
    80003536:	37e72703          	lw	a4,894(a4) # 800208b0 <sb>
    8000353a:	102037b7          	lui	a5,0x10203
    8000353e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003542:	02f71263          	bne	a4,a5,80003566 <fsinit+0x64>
  initlog(dev, &sb);
    80003546:	0001d597          	auipc	a1,0x1d
    8000354a:	36a58593          	addi	a1,a1,874 # 800208b0 <sb>
    8000354e:	854a                	mv	a0,s2
    80003550:	648000ef          	jal	80003b98 <initlog>
  ireclaim(dev);
    80003554:	854a                	mv	a0,s2
    80003556:	ee5ff0ef          	jal	8000343a <ireclaim>
}
    8000355a:	60e2                	ld	ra,24(sp)
    8000355c:	6442                	ld	s0,16(sp)
    8000355e:	64a2                	ld	s1,8(sp)
    80003560:	6902                	ld	s2,0(sp)
    80003562:	6105                	addi	sp,sp,32
    80003564:	8082                	ret
    panic("invalid file system");
    80003566:	00004517          	auipc	a0,0x4
    8000356a:	f2250513          	addi	a0,a0,-222 # 80007488 <etext+0x488>
    8000356e:	aaafd0ef          	jal	80000818 <panic>

0000000080003572 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003572:	1141                	addi	sp,sp,-16
    80003574:	e406                	sd	ra,8(sp)
    80003576:	e022                	sd	s0,0(sp)
    80003578:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000357a:	411c                	lw	a5,0(a0)
    8000357c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000357e:	415c                	lw	a5,4(a0)
    80003580:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003582:	04451783          	lh	a5,68(a0)
    80003586:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000358a:	04a51783          	lh	a5,74(a0)
    8000358e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003592:	04c56783          	lwu	a5,76(a0)
    80003596:	e99c                	sd	a5,16(a1)
}
    80003598:	60a2                	ld	ra,8(sp)
    8000359a:	6402                	ld	s0,0(sp)
    8000359c:	0141                	addi	sp,sp,16
    8000359e:	8082                	ret

00000000800035a0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800035a0:	457c                	lw	a5,76(a0)
    800035a2:	0ed7e663          	bltu	a5,a3,8000368e <readi+0xee>
{
    800035a6:	7159                	addi	sp,sp,-112
    800035a8:	f486                	sd	ra,104(sp)
    800035aa:	f0a2                	sd	s0,96(sp)
    800035ac:	eca6                	sd	s1,88(sp)
    800035ae:	e0d2                	sd	s4,64(sp)
    800035b0:	fc56                	sd	s5,56(sp)
    800035b2:	f85a                	sd	s6,48(sp)
    800035b4:	f45e                	sd	s7,40(sp)
    800035b6:	1880                	addi	s0,sp,112
    800035b8:	8b2a                	mv	s6,a0
    800035ba:	8bae                	mv	s7,a1
    800035bc:	8a32                	mv	s4,a2
    800035be:	84b6                	mv	s1,a3
    800035c0:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800035c2:	9f35                	addw	a4,a4,a3
    return 0;
    800035c4:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800035c6:	0ad76b63          	bltu	a4,a3,8000367c <readi+0xdc>
    800035ca:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800035cc:	00e7f463          	bgeu	a5,a4,800035d4 <readi+0x34>
    n = ip->size - off;
    800035d0:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800035d4:	080a8b63          	beqz	s5,8000366a <readi+0xca>
    800035d8:	e8ca                	sd	s2,80(sp)
    800035da:	f062                	sd	s8,32(sp)
    800035dc:	ec66                	sd	s9,24(sp)
    800035de:	e86a                	sd	s10,16(sp)
    800035e0:	e46e                	sd	s11,8(sp)
    800035e2:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800035e4:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800035e8:	5c7d                	li	s8,-1
    800035ea:	a80d                	j	8000361c <readi+0x7c>
    800035ec:	020d1d93          	slli	s11,s10,0x20
    800035f0:	020ddd93          	srli	s11,s11,0x20
    800035f4:	05890613          	addi	a2,s2,88
    800035f8:	86ee                	mv	a3,s11
    800035fa:	963e                	add	a2,a2,a5
    800035fc:	85d2                	mv	a1,s4
    800035fe:	855e                	mv	a0,s7
    80003600:	c63fe0ef          	jal	80002262 <either_copyout>
    80003604:	05850363          	beq	a0,s8,8000364a <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003608:	854a                	mv	a0,s2
    8000360a:	e74ff0ef          	jal	80002c7e <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000360e:	013d09bb          	addw	s3,s10,s3
    80003612:	009d04bb          	addw	s1,s10,s1
    80003616:	9a6e                	add	s4,s4,s11
    80003618:	0559f363          	bgeu	s3,s5,8000365e <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    8000361c:	00a4d59b          	srliw	a1,s1,0xa
    80003620:	855a                	mv	a0,s6
    80003622:	8bbff0ef          	jal	80002edc <bmap>
    80003626:	85aa                	mv	a1,a0
    if (addr == 0)
    80003628:	c139                	beqz	a0,8000366e <readi+0xce>
    bp = bread(ip->dev, addr);
    8000362a:	000b2503          	lw	a0,0(s6) # 80007468 <etext+0x468>
    8000362e:	d48ff0ef          	jal	80002b76 <bread>
    80003632:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003634:	3ff4f793          	andi	a5,s1,1023
    80003638:	40fc873b          	subw	a4,s9,a5
    8000363c:	413a86bb          	subw	a3,s5,s3
    80003640:	8d3a                	mv	s10,a4
    80003642:	fae6f5e3          	bgeu	a3,a4,800035ec <readi+0x4c>
    80003646:	8d36                	mv	s10,a3
    80003648:	b755                	j	800035ec <readi+0x4c>
      brelse(bp);
    8000364a:	854a                	mv	a0,s2
    8000364c:	e32ff0ef          	jal	80002c7e <brelse>
      tot = -1;
    80003650:	59fd                	li	s3,-1
      break;
    80003652:	6946                	ld	s2,80(sp)
    80003654:	7c02                	ld	s8,32(sp)
    80003656:	6ce2                	ld	s9,24(sp)
    80003658:	6d42                	ld	s10,16(sp)
    8000365a:	6da2                	ld	s11,8(sp)
    8000365c:	a831                	j	80003678 <readi+0xd8>
    8000365e:	6946                	ld	s2,80(sp)
    80003660:	7c02                	ld	s8,32(sp)
    80003662:	6ce2                	ld	s9,24(sp)
    80003664:	6d42                	ld	s10,16(sp)
    80003666:	6da2                	ld	s11,8(sp)
    80003668:	a801                	j	80003678 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000366a:	89d6                	mv	s3,s5
    8000366c:	a031                	j	80003678 <readi+0xd8>
    8000366e:	6946                	ld	s2,80(sp)
    80003670:	7c02                	ld	s8,32(sp)
    80003672:	6ce2                	ld	s9,24(sp)
    80003674:	6d42                	ld	s10,16(sp)
    80003676:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003678:	854e                	mv	a0,s3
    8000367a:	69a6                	ld	s3,72(sp)
}
    8000367c:	70a6                	ld	ra,104(sp)
    8000367e:	7406                	ld	s0,96(sp)
    80003680:	64e6                	ld	s1,88(sp)
    80003682:	6a06                	ld	s4,64(sp)
    80003684:	7ae2                	ld	s5,56(sp)
    80003686:	7b42                	ld	s6,48(sp)
    80003688:	7ba2                	ld	s7,40(sp)
    8000368a:	6165                	addi	sp,sp,112
    8000368c:	8082                	ret
    return 0;
    8000368e:	4501                	li	a0,0
}
    80003690:	8082                	ret

0000000080003692 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003692:	457c                	lw	a5,76(a0)
    80003694:	0ed7eb63          	bltu	a5,a3,8000378a <writei+0xf8>
{
    80003698:	7159                	addi	sp,sp,-112
    8000369a:	f486                	sd	ra,104(sp)
    8000369c:	f0a2                	sd	s0,96(sp)
    8000369e:	e8ca                	sd	s2,80(sp)
    800036a0:	e0d2                	sd	s4,64(sp)
    800036a2:	fc56                	sd	s5,56(sp)
    800036a4:	f85a                	sd	s6,48(sp)
    800036a6:	f45e                	sd	s7,40(sp)
    800036a8:	1880                	addi	s0,sp,112
    800036aa:	8aaa                	mv	s5,a0
    800036ac:	8bae                	mv	s7,a1
    800036ae:	8a32                	mv	s4,a2
    800036b0:	8936                	mv	s2,a3
    800036b2:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800036b4:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800036b8:	00043737          	lui	a4,0x43
    800036bc:	0cf76963          	bltu	a4,a5,8000378e <writei+0xfc>
    800036c0:	0cd7e763          	bltu	a5,a3,8000378e <writei+0xfc>
    800036c4:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800036c6:	0a0b0a63          	beqz	s6,8000377a <writei+0xe8>
    800036ca:	eca6                	sd	s1,88(sp)
    800036cc:	f062                	sd	s8,32(sp)
    800036ce:	ec66                	sd	s9,24(sp)
    800036d0:	e86a                	sd	s10,16(sp)
    800036d2:	e46e                	sd	s11,8(sp)
    800036d4:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800036d6:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800036da:	5c7d                	li	s8,-1
    800036dc:	a825                	j	80003714 <writei+0x82>
    800036de:	020d1d93          	slli	s11,s10,0x20
    800036e2:	020ddd93          	srli	s11,s11,0x20
    800036e6:	05848513          	addi	a0,s1,88
    800036ea:	86ee                	mv	a3,s11
    800036ec:	8652                	mv	a2,s4
    800036ee:	85de                	mv	a1,s7
    800036f0:	953e                	add	a0,a0,a5
    800036f2:	bbbfe0ef          	jal	800022ac <either_copyin>
    800036f6:	05850663          	beq	a0,s8,80003742 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800036fa:	8526                	mv	a0,s1
    800036fc:	6b0000ef          	jal	80003dac <log_write>
    brelse(bp);
    80003700:	8526                	mv	a0,s1
    80003702:	d7cff0ef          	jal	80002c7e <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003706:	013d09bb          	addw	s3,s10,s3
    8000370a:	012d093b          	addw	s2,s10,s2
    8000370e:	9a6e                	add	s4,s4,s11
    80003710:	0369fc63          	bgeu	s3,s6,80003748 <writei+0xb6>
    uint addr = bmap(ip, off / BSIZE);
    80003714:	00a9559b          	srliw	a1,s2,0xa
    80003718:	8556                	mv	a0,s5
    8000371a:	fc2ff0ef          	jal	80002edc <bmap>
    8000371e:	85aa                	mv	a1,a0
    if (addr == 0)
    80003720:	c505                	beqz	a0,80003748 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003722:	000aa503          	lw	a0,0(s5)
    80003726:	c50ff0ef          	jal	80002b76 <bread>
    8000372a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000372c:	3ff97793          	andi	a5,s2,1023
    80003730:	40fc873b          	subw	a4,s9,a5
    80003734:	413b06bb          	subw	a3,s6,s3
    80003738:	8d3a                	mv	s10,a4
    8000373a:	fae6f2e3          	bgeu	a3,a4,800036de <writei+0x4c>
    8000373e:	8d36                	mv	s10,a3
    80003740:	bf79                	j	800036de <writei+0x4c>
      brelse(bp);
    80003742:	8526                	mv	a0,s1
    80003744:	d3aff0ef          	jal	80002c7e <brelse>
  }

  if (off > ip->size)
    80003748:	04caa783          	lw	a5,76(s5)
    8000374c:	0327f963          	bgeu	a5,s2,8000377e <writei+0xec>
    ip->size = off;
    80003750:	052aa623          	sw	s2,76(s5)
    80003754:	64e6                	ld	s1,88(sp)
    80003756:	7c02                	ld	s8,32(sp)
    80003758:	6ce2                	ld	s9,24(sp)
    8000375a:	6d42                	ld	s10,16(sp)
    8000375c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000375e:	8556                	mv	a0,s5
    80003760:	9fbff0ef          	jal	8000315a <iupdate>

  return tot;
    80003764:	854e                	mv	a0,s3
    80003766:	69a6                	ld	s3,72(sp)
}
    80003768:	70a6                	ld	ra,104(sp)
    8000376a:	7406                	ld	s0,96(sp)
    8000376c:	6946                	ld	s2,80(sp)
    8000376e:	6a06                	ld	s4,64(sp)
    80003770:	7ae2                	ld	s5,56(sp)
    80003772:	7b42                	ld	s6,48(sp)
    80003774:	7ba2                	ld	s7,40(sp)
    80003776:	6165                	addi	sp,sp,112
    80003778:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000377a:	89da                	mv	s3,s6
    8000377c:	b7cd                	j	8000375e <writei+0xcc>
    8000377e:	64e6                	ld	s1,88(sp)
    80003780:	7c02                	ld	s8,32(sp)
    80003782:	6ce2                	ld	s9,24(sp)
    80003784:	6d42                	ld	s10,16(sp)
    80003786:	6da2                	ld	s11,8(sp)
    80003788:	bfd9                	j	8000375e <writei+0xcc>
    return -1;
    8000378a:	557d                	li	a0,-1
}
    8000378c:	8082                	ret
    return -1;
    8000378e:	557d                	li	a0,-1
    80003790:	bfe1                	j	80003768 <writei+0xd6>

0000000080003792 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003792:	1141                	addi	sp,sp,-16
    80003794:	e406                	sd	ra,8(sp)
    80003796:	e022                	sd	s0,0(sp)
    80003798:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000379a:	4639                	li	a2,14
    8000379c:	e04fd0ef          	jal	80000da0 <strncmp>
}
    800037a0:	60a2                	ld	ra,8(sp)
    800037a2:	6402                	ld	s0,0(sp)
    800037a4:	0141                	addi	sp,sp,16
    800037a6:	8082                	ret

00000000800037a8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800037a8:	711d                	addi	sp,sp,-96
    800037aa:	ec86                	sd	ra,88(sp)
    800037ac:	e8a2                	sd	s0,80(sp)
    800037ae:	e4a6                	sd	s1,72(sp)
    800037b0:	e0ca                	sd	s2,64(sp)
    800037b2:	fc4e                	sd	s3,56(sp)
    800037b4:	f852                	sd	s4,48(sp)
    800037b6:	f456                	sd	s5,40(sp)
    800037b8:	f05a                	sd	s6,32(sp)
    800037ba:	ec5e                	sd	s7,24(sp)
    800037bc:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800037be:	04451703          	lh	a4,68(a0)
    800037c2:	4785                	li	a5,1
    800037c4:	00f71f63          	bne	a4,a5,800037e2 <dirlookup+0x3a>
    800037c8:	892a                	mv	s2,a0
    800037ca:	8aae                	mv	s5,a1
    800037cc:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800037ce:	457c                	lw	a5,76(a0)
    800037d0:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037d2:	fa040a13          	addi	s4,s0,-96
    800037d6:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    800037d8:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800037dc:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800037de:	e39d                	bnez	a5,80003804 <dirlookup+0x5c>
    800037e0:	a8b9                	j	8000383e <dirlookup+0x96>
    panic("dirlookup not DIR");
    800037e2:	00004517          	auipc	a0,0x4
    800037e6:	cbe50513          	addi	a0,a0,-834 # 800074a0 <etext+0x4a0>
    800037ea:	82efd0ef          	jal	80000818 <panic>
      panic("dirlookup read");
    800037ee:	00004517          	auipc	a0,0x4
    800037f2:	cca50513          	addi	a0,a0,-822 # 800074b8 <etext+0x4b8>
    800037f6:	822fd0ef          	jal	80000818 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800037fa:	24c1                	addiw	s1,s1,16
    800037fc:	04c92783          	lw	a5,76(s2)
    80003800:	02f4fe63          	bgeu	s1,a5,8000383c <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003804:	874e                	mv	a4,s3
    80003806:	86a6                	mv	a3,s1
    80003808:	8652                	mv	a2,s4
    8000380a:	4581                	li	a1,0
    8000380c:	854a                	mv	a0,s2
    8000380e:	d93ff0ef          	jal	800035a0 <readi>
    80003812:	fd351ee3          	bne	a0,s3,800037ee <dirlookup+0x46>
    if (de.inum == 0)
    80003816:	fa045783          	lhu	a5,-96(s0)
    8000381a:	d3e5                	beqz	a5,800037fa <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    8000381c:	85da                	mv	a1,s6
    8000381e:	8556                	mv	a0,s5
    80003820:	f73ff0ef          	jal	80003792 <namecmp>
    80003824:	f979                	bnez	a0,800037fa <dirlookup+0x52>
      if (poff)
    80003826:	000b8463          	beqz	s7,8000382e <dirlookup+0x86>
        *poff = off;
    8000382a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000382e:	fa045583          	lhu	a1,-96(s0)
    80003832:	00092503          	lw	a0,0(s2)
    80003836:	f66ff0ef          	jal	80002f9c <iget>
    8000383a:	a011                	j	8000383e <dirlookup+0x96>
  return 0;
    8000383c:	4501                	li	a0,0
}
    8000383e:	60e6                	ld	ra,88(sp)
    80003840:	6446                	ld	s0,80(sp)
    80003842:	64a6                	ld	s1,72(sp)
    80003844:	6906                	ld	s2,64(sp)
    80003846:	79e2                	ld	s3,56(sp)
    80003848:	7a42                	ld	s4,48(sp)
    8000384a:	7aa2                	ld	s5,40(sp)
    8000384c:	7b02                	ld	s6,32(sp)
    8000384e:	6be2                	ld	s7,24(sp)
    80003850:	6125                	addi	sp,sp,96
    80003852:	8082                	ret

0000000080003854 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003854:	711d                	addi	sp,sp,-96
    80003856:	ec86                	sd	ra,88(sp)
    80003858:	e8a2                	sd	s0,80(sp)
    8000385a:	e4a6                	sd	s1,72(sp)
    8000385c:	e0ca                	sd	s2,64(sp)
    8000385e:	fc4e                	sd	s3,56(sp)
    80003860:	f852                	sd	s4,48(sp)
    80003862:	f456                	sd	s5,40(sp)
    80003864:	f05a                	sd	s6,32(sp)
    80003866:	ec5e                	sd	s7,24(sp)
    80003868:	e862                	sd	s8,16(sp)
    8000386a:	e466                	sd	s9,8(sp)
    8000386c:	e06a                	sd	s10,0(sp)
    8000386e:	1080                	addi	s0,sp,96
    80003870:	84aa                	mv	s1,a0
    80003872:	8b2e                	mv	s6,a1
    80003874:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003876:	00054703          	lbu	a4,0(a0)
    8000387a:	02f00793          	li	a5,47
    8000387e:	00f70f63          	beq	a4,a5,8000389c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003882:	880fe0ef          	jal	80001902 <myproc>
    80003886:	15053503          	ld	a0,336(a0)
    8000388a:	94fff0ef          	jal	800031d8 <idup>
    8000388e:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003890:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003894:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003896:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003898:	4b85                	li	s7,1
    8000389a:	a879                	j	80003938 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000389c:	4585                	li	a1,1
    8000389e:	852e                	mv	a0,a1
    800038a0:	efcff0ef          	jal	80002f9c <iget>
    800038a4:	8a2a                	mv	s4,a0
    800038a6:	b7ed                	j	80003890 <namex+0x3c>
      iunlockput(ip);
    800038a8:	8552                	mv	a0,s4
    800038aa:	b71ff0ef          	jal	8000341a <iunlockput>
      return 0;
    800038ae:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    800038b0:	8552                	mv	a0,s4
    800038b2:	60e6                	ld	ra,88(sp)
    800038b4:	6446                	ld	s0,80(sp)
    800038b6:	64a6                	ld	s1,72(sp)
    800038b8:	6906                	ld	s2,64(sp)
    800038ba:	79e2                	ld	s3,56(sp)
    800038bc:	7a42                	ld	s4,48(sp)
    800038be:	7aa2                	ld	s5,40(sp)
    800038c0:	7b02                	ld	s6,32(sp)
    800038c2:	6be2                	ld	s7,24(sp)
    800038c4:	6c42                	ld	s8,16(sp)
    800038c6:	6ca2                	ld	s9,8(sp)
    800038c8:	6d02                	ld	s10,0(sp)
    800038ca:	6125                	addi	sp,sp,96
    800038cc:	8082                	ret
      iunlock(ip);
    800038ce:	8552                	mv	a0,s4
    800038d0:	9edff0ef          	jal	800032bc <iunlock>
      return ip;
    800038d4:	bff1                	j	800038b0 <namex+0x5c>
      iunlockput(ip);
    800038d6:	8552                	mv	a0,s4
    800038d8:	b43ff0ef          	jal	8000341a <iunlockput>
      return 0;
    800038dc:	8a4a                	mv	s4,s2
    800038de:	bfc9                	j	800038b0 <namex+0x5c>
  len = path - s;
    800038e0:	40990633          	sub	a2,s2,s1
    800038e4:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    800038e8:	09ac5463          	bge	s8,s10,80003970 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    800038ec:	8666                	mv	a2,s9
    800038ee:	85a6                	mv	a1,s1
    800038f0:	8556                	mv	a0,s5
    800038f2:	c3afd0ef          	jal	80000d2c <memmove>
    800038f6:	84ca                	mv	s1,s2
  while (*path == '/')
    800038f8:	0004c783          	lbu	a5,0(s1)
    800038fc:	01379763          	bne	a5,s3,8000390a <namex+0xb6>
    path++;
    80003900:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003902:	0004c783          	lbu	a5,0(s1)
    80003906:	ff378de3          	beq	a5,s3,80003900 <namex+0xac>
    ilock(ip);
    8000390a:	8552                	mv	a0,s4
    8000390c:	903ff0ef          	jal	8000320e <ilock>
    if (ip->type != T_DIR) {
    80003910:	044a1783          	lh	a5,68(s4)
    80003914:	f9779ae3          	bne	a5,s7,800038a8 <namex+0x54>
    if (nameiparent && *path == '\0') {
    80003918:	000b0563          	beqz	s6,80003922 <namex+0xce>
    8000391c:	0004c783          	lbu	a5,0(s1)
    80003920:	d7dd                	beqz	a5,800038ce <namex+0x7a>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003922:	4601                	li	a2,0
    80003924:	85d6                	mv	a1,s5
    80003926:	8552                	mv	a0,s4
    80003928:	e81ff0ef          	jal	800037a8 <dirlookup>
    8000392c:	892a                	mv	s2,a0
    8000392e:	d545                	beqz	a0,800038d6 <namex+0x82>
    iunlockput(ip);
    80003930:	8552                	mv	a0,s4
    80003932:	ae9ff0ef          	jal	8000341a <iunlockput>
    ip = next;
    80003936:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003938:	0004c783          	lbu	a5,0(s1)
    8000393c:	01379763          	bne	a5,s3,8000394a <namex+0xf6>
    path++;
    80003940:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003942:	0004c783          	lbu	a5,0(s1)
    80003946:	ff378de3          	beq	a5,s3,80003940 <namex+0xec>
  if (*path == 0)
    8000394a:	cf8d                	beqz	a5,80003984 <namex+0x130>
  while (*path != '/' && *path != 0)
    8000394c:	0004c783          	lbu	a5,0(s1)
    80003950:	fd178713          	addi	a4,a5,-47
    80003954:	cb19                	beqz	a4,8000396a <namex+0x116>
    80003956:	cb91                	beqz	a5,8000396a <namex+0x116>
    80003958:	8926                	mv	s2,s1
    path++;
    8000395a:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    8000395c:	00094783          	lbu	a5,0(s2)
    80003960:	fd178713          	addi	a4,a5,-47
    80003964:	df35                	beqz	a4,800038e0 <namex+0x8c>
    80003966:	fbf5                	bnez	a5,8000395a <namex+0x106>
    80003968:	bfa5                	j	800038e0 <namex+0x8c>
    8000396a:	8926                	mv	s2,s1
  len = path - s;
    8000396c:	4d01                	li	s10,0
    8000396e:	4601                	li	a2,0
    memmove(name, s, len);
    80003970:	2601                	sext.w	a2,a2
    80003972:	85a6                	mv	a1,s1
    80003974:	8556                	mv	a0,s5
    80003976:	bb6fd0ef          	jal	80000d2c <memmove>
    name[len] = 0;
    8000397a:	9d56                	add	s10,s10,s5
    8000397c:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdba48>
    80003980:	84ca                	mv	s1,s2
    80003982:	bf9d                	j	800038f8 <namex+0xa4>
  if (nameiparent) {
    80003984:	f20b06e3          	beqz	s6,800038b0 <namex+0x5c>
    iput(ip);
    80003988:	8552                	mv	a0,s4
    8000398a:	a07ff0ef          	jal	80003390 <iput>
    return 0;
    8000398e:	4a01                	li	s4,0
    80003990:	b705                	j	800038b0 <namex+0x5c>

0000000080003992 <dirlink>:
{
    80003992:	715d                	addi	sp,sp,-80
    80003994:	e486                	sd	ra,72(sp)
    80003996:	e0a2                	sd	s0,64(sp)
    80003998:	f84a                	sd	s2,48(sp)
    8000399a:	ec56                	sd	s5,24(sp)
    8000399c:	e85a                	sd	s6,16(sp)
    8000399e:	0880                	addi	s0,sp,80
    800039a0:	892a                	mv	s2,a0
    800039a2:	8aae                	mv	s5,a1
    800039a4:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    800039a6:	4601                	li	a2,0
    800039a8:	e01ff0ef          	jal	800037a8 <dirlookup>
    800039ac:	ed1d                	bnez	a0,800039ea <dirlink+0x58>
    800039ae:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039b0:	04c92483          	lw	s1,76(s2)
    800039b4:	c4b9                	beqz	s1,80003a02 <dirlink+0x70>
    800039b6:	f44e                	sd	s3,40(sp)
    800039b8:	f052                	sd	s4,32(sp)
    800039ba:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039bc:	fb040a13          	addi	s4,s0,-80
    800039c0:	49c1                	li	s3,16
    800039c2:	874e                	mv	a4,s3
    800039c4:	86a6                	mv	a3,s1
    800039c6:	8652                	mv	a2,s4
    800039c8:	4581                	li	a1,0
    800039ca:	854a                	mv	a0,s2
    800039cc:	bd5ff0ef          	jal	800035a0 <readi>
    800039d0:	03351163          	bne	a0,s3,800039f2 <dirlink+0x60>
    if (de.inum == 0)
    800039d4:	fb045783          	lhu	a5,-80(s0)
    800039d8:	c39d                	beqz	a5,800039fe <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039da:	24c1                	addiw	s1,s1,16
    800039dc:	04c92783          	lw	a5,76(s2)
    800039e0:	fef4e1e3          	bltu	s1,a5,800039c2 <dirlink+0x30>
    800039e4:	79a2                	ld	s3,40(sp)
    800039e6:	7a02                	ld	s4,32(sp)
    800039e8:	a829                	j	80003a02 <dirlink+0x70>
    iput(ip);
    800039ea:	9a7ff0ef          	jal	80003390 <iput>
    return -1;
    800039ee:	557d                	li	a0,-1
    800039f0:	a83d                	j	80003a2e <dirlink+0x9c>
      panic("dirlink read");
    800039f2:	00004517          	auipc	a0,0x4
    800039f6:	ad650513          	addi	a0,a0,-1322 # 800074c8 <etext+0x4c8>
    800039fa:	e1ffc0ef          	jal	80000818 <panic>
    800039fe:	79a2                	ld	s3,40(sp)
    80003a00:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003a02:	4639                	li	a2,14
    80003a04:	85d6                	mv	a1,s5
    80003a06:	fb240513          	addi	a0,s0,-78
    80003a0a:	bd0fd0ef          	jal	80000dda <strncpy>
  de.inum = inum;
    80003a0e:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a12:	4741                	li	a4,16
    80003a14:	86a6                	mv	a3,s1
    80003a16:	fb040613          	addi	a2,s0,-80
    80003a1a:	4581                	li	a1,0
    80003a1c:	854a                	mv	a0,s2
    80003a1e:	c75ff0ef          	jal	80003692 <writei>
    80003a22:	1541                	addi	a0,a0,-16
    80003a24:	00a03533          	snez	a0,a0
    80003a28:	40a0053b          	negw	a0,a0
    80003a2c:	74e2                	ld	s1,56(sp)
}
    80003a2e:	60a6                	ld	ra,72(sp)
    80003a30:	6406                	ld	s0,64(sp)
    80003a32:	7942                	ld	s2,48(sp)
    80003a34:	6ae2                	ld	s5,24(sp)
    80003a36:	6b42                	ld	s6,16(sp)
    80003a38:	6161                	addi	sp,sp,80
    80003a3a:	8082                	ret

0000000080003a3c <namei>:

struct inode *
namei(char *path)
{
    80003a3c:	1101                	addi	sp,sp,-32
    80003a3e:	ec06                	sd	ra,24(sp)
    80003a40:	e822                	sd	s0,16(sp)
    80003a42:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a44:	fe040613          	addi	a2,s0,-32
    80003a48:	4581                	li	a1,0
    80003a4a:	e0bff0ef          	jal	80003854 <namex>
}
    80003a4e:	60e2                	ld	ra,24(sp)
    80003a50:	6442                	ld	s0,16(sp)
    80003a52:	6105                	addi	sp,sp,32
    80003a54:	8082                	ret

0000000080003a56 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003a56:	1141                	addi	sp,sp,-16
    80003a58:	e406                	sd	ra,8(sp)
    80003a5a:	e022                	sd	s0,0(sp)
    80003a5c:	0800                	addi	s0,sp,16
    80003a5e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a60:	4585                	li	a1,1
    80003a62:	df3ff0ef          	jal	80003854 <namex>
}
    80003a66:	60a2                	ld	ra,8(sp)
    80003a68:	6402                	ld	s0,0(sp)
    80003a6a:	0141                	addi	sp,sp,16
    80003a6c:	8082                	ret

0000000080003a6e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a6e:	1101                	addi	sp,sp,-32
    80003a70:	ec06                	sd	ra,24(sp)
    80003a72:	e822                	sd	s0,16(sp)
    80003a74:	e426                	sd	s1,8(sp)
    80003a76:	e04a                	sd	s2,0(sp)
    80003a78:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a7a:	0001f917          	auipc	s2,0x1f
    80003a7e:	8fe90913          	addi	s2,s2,-1794 # 80022378 <log>
    80003a82:	01892583          	lw	a1,24(s2)
    80003a86:	02492503          	lw	a0,36(s2)
    80003a8a:	8ecff0ef          	jal	80002b76 <bread>
    80003a8e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003a90:	02c92603          	lw	a2,44(s2)
    80003a94:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a96:	00c05f63          	blez	a2,80003ab4 <write_head+0x46>
    80003a9a:	0001f717          	auipc	a4,0x1f
    80003a9e:	90e70713          	addi	a4,a4,-1778 # 800223a8 <log+0x30>
    80003aa2:	87aa                	mv	a5,a0
    80003aa4:	060a                	slli	a2,a2,0x2
    80003aa6:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003aa8:	4314                	lw	a3,0(a4)
    80003aaa:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003aac:	0711                	addi	a4,a4,4
    80003aae:	0791                	addi	a5,a5,4
    80003ab0:	fec79ce3          	bne	a5,a2,80003aa8 <write_head+0x3a>
  }
  bwrite(buf);
    80003ab4:	8526                	mv	a0,s1
    80003ab6:	996ff0ef          	jal	80002c4c <bwrite>
  brelse(buf);
    80003aba:	8526                	mv	a0,s1
    80003abc:	9c2ff0ef          	jal	80002c7e <brelse>
}
    80003ac0:	60e2                	ld	ra,24(sp)
    80003ac2:	6442                	ld	s0,16(sp)
    80003ac4:	64a2                	ld	s1,8(sp)
    80003ac6:	6902                	ld	s2,0(sp)
    80003ac8:	6105                	addi	sp,sp,32
    80003aca:	8082                	ret

0000000080003acc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003acc:	0001f797          	auipc	a5,0x1f
    80003ad0:	8d87a783          	lw	a5,-1832(a5) # 800223a4 <log+0x2c>
    80003ad4:	0cf05163          	blez	a5,80003b96 <install_trans+0xca>
{
    80003ad8:	715d                	addi	sp,sp,-80
    80003ada:	e486                	sd	ra,72(sp)
    80003adc:	e0a2                	sd	s0,64(sp)
    80003ade:	fc26                	sd	s1,56(sp)
    80003ae0:	f84a                	sd	s2,48(sp)
    80003ae2:	f44e                	sd	s3,40(sp)
    80003ae4:	f052                	sd	s4,32(sp)
    80003ae6:	ec56                	sd	s5,24(sp)
    80003ae8:	e85a                	sd	s6,16(sp)
    80003aea:	e45e                	sd	s7,8(sp)
    80003aec:	e062                	sd	s8,0(sp)
    80003aee:	0880                	addi	s0,sp,80
    80003af0:	8b2a                	mv	s6,a0
    80003af2:	0001fa97          	auipc	s5,0x1f
    80003af6:	8b6a8a93          	addi	s5,s5,-1866 # 800223a8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003afa:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003afc:	00004c17          	auipc	s8,0x4
    80003b00:	9dcc0c13          	addi	s8,s8,-1572 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003b04:	0001fa17          	auipc	s4,0x1f
    80003b08:	874a0a13          	addi	s4,s4,-1932 # 80022378 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003b0c:	40000b93          	li	s7,1024
    80003b10:	a025                	j	80003b38 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b12:	000aa603          	lw	a2,0(s5)
    80003b16:	85ce                	mv	a1,s3
    80003b18:	8562                	mv	a0,s8
    80003b1a:	9d5fc0ef          	jal	800004ee <printk>
    80003b1e:	a839                	j	80003b3c <install_trans+0x70>
    brelse(lbuf);
    80003b20:	854a                	mv	a0,s2
    80003b22:	95cff0ef          	jal	80002c7e <brelse>
    brelse(dbuf);
    80003b26:	8526                	mv	a0,s1
    80003b28:	956ff0ef          	jal	80002c7e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b2c:	2985                	addiw	s3,s3,1
    80003b2e:	0a91                	addi	s5,s5,4
    80003b30:	02ca2783          	lw	a5,44(s4)
    80003b34:	04f9d563          	bge	s3,a5,80003b7e <install_trans+0xb2>
    if (recovering) {
    80003b38:	fc0b1de3          	bnez	s6,80003b12 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003b3c:	018a2583          	lw	a1,24(s4)
    80003b40:	013585bb          	addw	a1,a1,s3
    80003b44:	2585                	addiw	a1,a1,1
    80003b46:	024a2503          	lw	a0,36(s4)
    80003b4a:	82cff0ef          	jal	80002b76 <bread>
    80003b4e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003b50:	000aa583          	lw	a1,0(s5)
    80003b54:	024a2503          	lw	a0,36(s4)
    80003b58:	81eff0ef          	jal	80002b76 <bread>
    80003b5c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003b5e:	865e                	mv	a2,s7
    80003b60:	05890593          	addi	a1,s2,88
    80003b64:	05850513          	addi	a0,a0,88
    80003b68:	9c4fd0ef          	jal	80000d2c <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003b6c:	8526                	mv	a0,s1
    80003b6e:	8deff0ef          	jal	80002c4c <bwrite>
    if (recovering == 0)
    80003b72:	fa0b17e3          	bnez	s6,80003b20 <install_trans+0x54>
      bunpin(dbuf);
    80003b76:	8526                	mv	a0,s1
    80003b78:	9beff0ef          	jal	80002d36 <bunpin>
    80003b7c:	b755                	j	80003b20 <install_trans+0x54>
}
    80003b7e:	60a6                	ld	ra,72(sp)
    80003b80:	6406                	ld	s0,64(sp)
    80003b82:	74e2                	ld	s1,56(sp)
    80003b84:	7942                	ld	s2,48(sp)
    80003b86:	79a2                	ld	s3,40(sp)
    80003b88:	7a02                	ld	s4,32(sp)
    80003b8a:	6ae2                	ld	s5,24(sp)
    80003b8c:	6b42                	ld	s6,16(sp)
    80003b8e:	6ba2                	ld	s7,8(sp)
    80003b90:	6c02                	ld	s8,0(sp)
    80003b92:	6161                	addi	sp,sp,80
    80003b94:	8082                	ret
    80003b96:	8082                	ret

0000000080003b98 <initlog>:
{
    80003b98:	7179                	addi	sp,sp,-48
    80003b9a:	f406                	sd	ra,40(sp)
    80003b9c:	f022                	sd	s0,32(sp)
    80003b9e:	ec26                	sd	s1,24(sp)
    80003ba0:	e84a                	sd	s2,16(sp)
    80003ba2:	e44e                	sd	s3,8(sp)
    80003ba4:	1800                	addi	s0,sp,48
    80003ba6:	84aa                	mv	s1,a0
    80003ba8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003baa:	0001e917          	auipc	s2,0x1e
    80003bae:	7ce90913          	addi	s2,s2,1998 # 80022378 <log>
    80003bb2:	00004597          	auipc	a1,0x4
    80003bb6:	94658593          	addi	a1,a1,-1722 # 800074f8 <etext+0x4f8>
    80003bba:	854a                	mv	a0,s2
    80003bbc:	fbffc0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003bc0:	0149a583          	lw	a1,20(s3)
    80003bc4:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003bc8:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003bcc:	8526                	mv	a0,s1
    80003bce:	fa9fe0ef          	jal	80002b76 <bread>
  log.lh.n = lh->n;
    80003bd2:	4d30                	lw	a2,88(a0)
    80003bd4:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003bd8:	00c05f63          	blez	a2,80003bf6 <initlog+0x5e>
    80003bdc:	87aa                	mv	a5,a0
    80003bde:	0001e717          	auipc	a4,0x1e
    80003be2:	7ca70713          	addi	a4,a4,1994 # 800223a8 <log+0x30>
    80003be6:	060a                	slli	a2,a2,0x2
    80003be8:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003bea:	4ff4                	lw	a3,92(a5)
    80003bec:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003bee:	0791                	addi	a5,a5,4
    80003bf0:	0711                	addi	a4,a4,4
    80003bf2:	fec79ce3          	bne	a5,a2,80003bea <initlog+0x52>
  brelse(buf);
    80003bf6:	888ff0ef          	jal	80002c7e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003bfa:	4505                	li	a0,1
    80003bfc:	ed1ff0ef          	jal	80003acc <install_trans>
  log.lh.n = 0;
    80003c00:	0001e797          	auipc	a5,0x1e
    80003c04:	7a07a223          	sw	zero,1956(a5) # 800223a4 <log+0x2c>
  write_head(); // clear the log
    80003c08:	e67ff0ef          	jal	80003a6e <write_head>
}
    80003c0c:	70a2                	ld	ra,40(sp)
    80003c0e:	7402                	ld	s0,32(sp)
    80003c10:	64e2                	ld	s1,24(sp)
    80003c12:	6942                	ld	s2,16(sp)
    80003c14:	69a2                	ld	s3,8(sp)
    80003c16:	6145                	addi	sp,sp,48
    80003c18:	8082                	ret

0000000080003c1a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c1a:	1101                	addi	sp,sp,-32
    80003c1c:	ec06                	sd	ra,24(sp)
    80003c1e:	e822                	sd	s0,16(sp)
    80003c20:	e426                	sd	s1,8(sp)
    80003c22:	e04a                	sd	s2,0(sp)
    80003c24:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c26:	0001e517          	auipc	a0,0x1e
    80003c2a:	75250513          	addi	a0,a0,1874 # 80022378 <log>
    80003c2e:	fd7fc0ef          	jal	80000c04 <acquire>
  while (1) {
    if (log.committing) {
    80003c32:	0001e497          	auipc	s1,0x1e
    80003c36:	74648493          	addi	s1,s1,1862 # 80022378 <log>
      sleep(&log, &log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003c3a:	4979                	li	s2,30
    80003c3c:	a029                	j	80003c46 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003c3e:	85a6                	mv	a1,s1
    80003c40:	8526                	mv	a0,s1
    80003c42:	ac6fe0ef          	jal	80001f08 <sleep>
    if (log.committing) {
    80003c46:	509c                	lw	a5,32(s1)
    80003c48:	fbfd                	bnez	a5,80003c3e <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003c4a:	4cd8                	lw	a4,28(s1)
    80003c4c:	2705                	addiw	a4,a4,1
    80003c4e:	0027179b          	slliw	a5,a4,0x2
    80003c52:	9fb9                	addw	a5,a5,a4
    80003c54:	0017979b          	slliw	a5,a5,0x1
    80003c58:	54d4                	lw	a3,44(s1)
    80003c5a:	9fb5                	addw	a5,a5,a3
    80003c5c:	00f95763          	bge	s2,a5,80003c6a <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c60:	85a6                	mv	a1,s1
    80003c62:	8526                	mv	a0,s1
    80003c64:	aa4fe0ef          	jal	80001f08 <sleep>
    80003c68:	bff9                	j	80003c46 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c6a:	0001e797          	auipc	a5,0x1e
    80003c6e:	72e7a523          	sw	a4,1834(a5) # 80022394 <log+0x1c>
      release(&log.lock);
    80003c72:	0001e517          	auipc	a0,0x1e
    80003c76:	70650513          	addi	a0,a0,1798 # 80022378 <log>
    80003c7a:	81afd0ef          	jal	80000c94 <release>
      break;
    }
  }
}
    80003c7e:	60e2                	ld	ra,24(sp)
    80003c80:	6442                	ld	s0,16(sp)
    80003c82:	64a2                	ld	s1,8(sp)
    80003c84:	6902                	ld	s2,0(sp)
    80003c86:	6105                	addi	sp,sp,32
    80003c88:	8082                	ret

0000000080003c8a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c8a:	7139                	addi	sp,sp,-64
    80003c8c:	fc06                	sd	ra,56(sp)
    80003c8e:	f822                	sd	s0,48(sp)
    80003c90:	f426                	sd	s1,40(sp)
    80003c92:	f04a                	sd	s2,32(sp)
    80003c94:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c96:	0001e497          	auipc	s1,0x1e
    80003c9a:	6e248493          	addi	s1,s1,1762 # 80022378 <log>
    80003c9e:	8526                	mv	a0,s1
    80003ca0:	f65fc0ef          	jal	80000c04 <acquire>
  log.outstanding -= 1;
    80003ca4:	4cdc                	lw	a5,28(s1)
    80003ca6:	37fd                	addiw	a5,a5,-1
    80003ca8:	893e                	mv	s2,a5
    80003caa:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003cac:	509c                	lw	a5,32(s1)
    80003cae:	e3b1                	bnez	a5,80003cf2 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003cb0:	04091a63          	bnez	s2,80003d04 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003cb4:	0001e497          	auipc	s1,0x1e
    80003cb8:	6c448493          	addi	s1,s1,1732 # 80022378 <log>
    80003cbc:	4785                	li	a5,1
    80003cbe:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003cc0:	8526                	mv	a0,s1
    80003cc2:	fd3fc0ef          	jal	80000c94 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003cc6:	54dc                	lw	a5,44(s1)
    80003cc8:	06f04063          	bgtz	a5,80003d28 <end_op+0x9e>
    acquire(&log.lock);
    80003ccc:	0001e497          	auipc	s1,0x1e
    80003cd0:	6ac48493          	addi	s1,s1,1708 # 80022378 <log>
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	f2ffc0ef          	jal	80000c04 <acquire>
    log.committing = 0;
    80003cda:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003cde:	549c                	lw	a5,40(s1)
    80003ce0:	2785                	addiw	a5,a5,1
    80003ce2:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003ce4:	8526                	mv	a0,s1
    80003ce6:	a6efe0ef          	jal	80001f54 <wakeup>
    release(&log.lock);
    80003cea:	8526                	mv	a0,s1
    80003cec:	fa9fc0ef          	jal	80000c94 <release>
}
    80003cf0:	a035                	j	80003d1c <end_op+0x92>
    80003cf2:	ec4e                	sd	s3,24(sp)
    80003cf4:	e852                	sd	s4,16(sp)
    80003cf6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003cf8:	00004517          	auipc	a0,0x4
    80003cfc:	80850513          	addi	a0,a0,-2040 # 80007500 <etext+0x500>
    80003d00:	b19fc0ef          	jal	80000818 <panic>
    wakeup(&log);
    80003d04:	0001e517          	auipc	a0,0x1e
    80003d08:	67450513          	addi	a0,a0,1652 # 80022378 <log>
    80003d0c:	a48fe0ef          	jal	80001f54 <wakeup>
  release(&log.lock);
    80003d10:	0001e517          	auipc	a0,0x1e
    80003d14:	66850513          	addi	a0,a0,1640 # 80022378 <log>
    80003d18:	f7dfc0ef          	jal	80000c94 <release>
}
    80003d1c:	70e2                	ld	ra,56(sp)
    80003d1e:	7442                	ld	s0,48(sp)
    80003d20:	74a2                	ld	s1,40(sp)
    80003d22:	7902                	ld	s2,32(sp)
    80003d24:	6121                	addi	sp,sp,64
    80003d26:	8082                	ret
    80003d28:	ec4e                	sd	s3,24(sp)
    80003d2a:	e852                	sd	s4,16(sp)
    80003d2c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d2e:	0001ea97          	auipc	s5,0x1e
    80003d32:	67aa8a93          	addi	s5,s5,1658 # 800223a8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003d36:	0001ea17          	auipc	s4,0x1e
    80003d3a:	642a0a13          	addi	s4,s4,1602 # 80022378 <log>
    80003d3e:	018a2583          	lw	a1,24(s4)
    80003d42:	012585bb          	addw	a1,a1,s2
    80003d46:	2585                	addiw	a1,a1,1
    80003d48:	024a2503          	lw	a0,36(s4)
    80003d4c:	e2bfe0ef          	jal	80002b76 <bread>
    80003d50:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003d52:	000aa583          	lw	a1,0(s5)
    80003d56:	024a2503          	lw	a0,36(s4)
    80003d5a:	e1dfe0ef          	jal	80002b76 <bread>
    80003d5e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d60:	40000613          	li	a2,1024
    80003d64:	05850593          	addi	a1,a0,88
    80003d68:	05848513          	addi	a0,s1,88
    80003d6c:	fc1fc0ef          	jal	80000d2c <memmove>
    bwrite(to); // write the log
    80003d70:	8526                	mv	a0,s1
    80003d72:	edbfe0ef          	jal	80002c4c <bwrite>
    brelse(from);
    80003d76:	854e                	mv	a0,s3
    80003d78:	f07fe0ef          	jal	80002c7e <brelse>
    brelse(to);
    80003d7c:	8526                	mv	a0,s1
    80003d7e:	f01fe0ef          	jal	80002c7e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d82:	2905                	addiw	s2,s2,1
    80003d84:	0a91                	addi	s5,s5,4
    80003d86:	02ca2783          	lw	a5,44(s4)
    80003d8a:	faf94ae3          	blt	s2,a5,80003d3e <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003d8e:	ce1ff0ef          	jal	80003a6e <write_head>
    install_trans(0); // Now install writes to home locations
    80003d92:	4501                	li	a0,0
    80003d94:	d39ff0ef          	jal	80003acc <install_trans>
    log.lh.n = 0;
    80003d98:	0001e797          	auipc	a5,0x1e
    80003d9c:	6007a623          	sw	zero,1548(a5) # 800223a4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003da0:	ccfff0ef          	jal	80003a6e <write_head>
    80003da4:	69e2                	ld	s3,24(sp)
    80003da6:	6a42                	ld	s4,16(sp)
    80003da8:	6aa2                	ld	s5,8(sp)
    80003daa:	b70d                	j	80003ccc <end_op+0x42>

0000000080003dac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003dac:	1101                	addi	sp,sp,-32
    80003dae:	ec06                	sd	ra,24(sp)
    80003db0:	e822                	sd	s0,16(sp)
    80003db2:	e426                	sd	s1,8(sp)
    80003db4:	1000                	addi	s0,sp,32
    80003db6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003db8:	0001e517          	auipc	a0,0x1e
    80003dbc:	5c050513          	addi	a0,a0,1472 # 80022378 <log>
    80003dc0:	e45fc0ef          	jal	80000c04 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003dc4:	0001e617          	auipc	a2,0x1e
    80003dc8:	5e062603          	lw	a2,1504(a2) # 800223a4 <log+0x2c>
    80003dcc:	47f5                	li	a5,29
    80003dce:	04c7cd63          	blt	a5,a2,80003e28 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003dd2:	0001e797          	auipc	a5,0x1e
    80003dd6:	5c27a783          	lw	a5,1474(a5) # 80022394 <log+0x1c>
    80003dda:	04f05d63          	blez	a5,80003e34 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003dde:	4781                	li	a5,0
    80003de0:	06c05063          	blez	a2,80003e40 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003de4:	44cc                	lw	a1,12(s1)
    80003de6:	0001e717          	auipc	a4,0x1e
    80003dea:	5c270713          	addi	a4,a4,1474 # 800223a8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003dee:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003df0:	4314                	lw	a3,0(a4)
    80003df2:	04b68763          	beq	a3,a1,80003e40 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003df6:	2785                	addiw	a5,a5,1
    80003df8:	0711                	addi	a4,a4,4
    80003dfa:	fef61be3          	bne	a2,a5,80003df0 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003dfe:	060a                	slli	a2,a2,0x2
    80003e00:	02060613          	addi	a2,a2,32
    80003e04:	0001e797          	auipc	a5,0x1e
    80003e08:	57478793          	addi	a5,a5,1396 # 80022378 <log>
    80003e0c:	97b2                	add	a5,a5,a2
    80003e0e:	44d8                	lw	a4,12(s1)
    80003e10:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003e12:	8526                	mv	a0,s1
    80003e14:	eeffe0ef          	jal	80002d02 <bpin>
    log.lh.n++;
    80003e18:	0001e717          	auipc	a4,0x1e
    80003e1c:	56070713          	addi	a4,a4,1376 # 80022378 <log>
    80003e20:	575c                	lw	a5,44(a4)
    80003e22:	2785                	addiw	a5,a5,1
    80003e24:	d75c                	sw	a5,44(a4)
    80003e26:	a815                	j	80003e5a <log_write+0xae>
    panic("too big a transaction");
    80003e28:	00003517          	auipc	a0,0x3
    80003e2c:	6e850513          	addi	a0,a0,1768 # 80007510 <etext+0x510>
    80003e30:	9e9fc0ef          	jal	80000818 <panic>
    panic("log_write outside of trans");
    80003e34:	00003517          	auipc	a0,0x3
    80003e38:	6f450513          	addi	a0,a0,1780 # 80007528 <etext+0x528>
    80003e3c:	9ddfc0ef          	jal	80000818 <panic>
  log.lh.block[i] = b->blockno;
    80003e40:	00279693          	slli	a3,a5,0x2
    80003e44:	02068693          	addi	a3,a3,32
    80003e48:	0001e717          	auipc	a4,0x1e
    80003e4c:	53070713          	addi	a4,a4,1328 # 80022378 <log>
    80003e50:	9736                	add	a4,a4,a3
    80003e52:	44d4                	lw	a3,12(s1)
    80003e54:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003e56:	faf60ee3          	beq	a2,a5,80003e12 <log_write+0x66>
  }
  release(&log.lock);
    80003e5a:	0001e517          	auipc	a0,0x1e
    80003e5e:	51e50513          	addi	a0,a0,1310 # 80022378 <log>
    80003e62:	e33fc0ef          	jal	80000c94 <release>
}
    80003e66:	60e2                	ld	ra,24(sp)
    80003e68:	6442                	ld	s0,16(sp)
    80003e6a:	64a2                	ld	s1,8(sp)
    80003e6c:	6105                	addi	sp,sp,32
    80003e6e:	8082                	ret

0000000080003e70 <sys_sync>:

uint64
sys_sync(void)
{
    80003e70:	1101                	addi	sp,sp,-32
    80003e72:	ec06                	sd	ra,24(sp)
    80003e74:	e822                	sd	s0,16(sp)
    80003e76:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e78:	0001e517          	auipc	a0,0x1e
    80003e7c:	50050513          	addi	a0,a0,1280 # 80022378 <log>
    80003e80:	d85fc0ef          	jal	80000c04 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003e84:	0001e797          	auipc	a5,0x1e
    80003e88:	5147a783          	lw	a5,1300(a5) # 80022398 <log+0x20>
    80003e8c:	e799                	bnez	a5,80003e9a <sys_sync+0x2a>
    80003e8e:	0001e797          	auipc	a5,0x1e
    80003e92:	5067a783          	lw	a5,1286(a5) # 80022394 <log+0x1c>
    80003e96:	02f05563          	blez	a5,80003ec0 <sys_sync+0x50>
    80003e9a:	e426                	sd	s1,8(sp)
    80003e9c:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003e9e:	0001e917          	auipc	s2,0x1e
    80003ea2:	50292903          	lw	s2,1282(s2) # 800223a0 <log+0x28>
    while (log.ncommit < n) {
      sleep(&log, &log.lock);
    80003ea6:	0001e497          	auipc	s1,0x1e
    80003eaa:	4d248493          	addi	s1,s1,1234 # 80022378 <log>
    80003eae:	85a6                	mv	a1,s1
    80003eb0:	8526                	mv	a0,s1
    80003eb2:	856fe0ef          	jal	80001f08 <sleep>
    while (log.ncommit < n) {
    80003eb6:	549c                	lw	a5,40(s1)
    80003eb8:	fef95be3          	bge	s2,a5,80003eae <sys_sync+0x3e>
    80003ebc:	64a2                	ld	s1,8(sp)
    80003ebe:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003ec0:	0001e517          	auipc	a0,0x1e
    80003ec4:	4b850513          	addi	a0,a0,1208 # 80022378 <log>
    80003ec8:	dcdfc0ef          	jal	80000c94 <release>
  return 0;
}
    80003ecc:	4501                	li	a0,0
    80003ece:	60e2                	ld	ra,24(sp)
    80003ed0:	6442                	ld	s0,16(sp)
    80003ed2:	6105                	addi	sp,sp,32
    80003ed4:	8082                	ret

0000000080003ed6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003ed6:	1101                	addi	sp,sp,-32
    80003ed8:	ec06                	sd	ra,24(sp)
    80003eda:	e822                	sd	s0,16(sp)
    80003edc:	e426                	sd	s1,8(sp)
    80003ede:	e04a                	sd	s2,0(sp)
    80003ee0:	1000                	addi	s0,sp,32
    80003ee2:	84aa                	mv	s1,a0
    80003ee4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ee6:	00003597          	auipc	a1,0x3
    80003eea:	66258593          	addi	a1,a1,1634 # 80007548 <etext+0x548>
    80003eee:	0521                	addi	a0,a0,8
    80003ef0:	c8bfc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80003ef4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003ef8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003efc:	0204a423          	sw	zero,40(s1)
}
    80003f00:	60e2                	ld	ra,24(sp)
    80003f02:	6442                	ld	s0,16(sp)
    80003f04:	64a2                	ld	s1,8(sp)
    80003f06:	6902                	ld	s2,0(sp)
    80003f08:	6105                	addi	sp,sp,32
    80003f0a:	8082                	ret

0000000080003f0c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f0c:	1101                	addi	sp,sp,-32
    80003f0e:	ec06                	sd	ra,24(sp)
    80003f10:	e822                	sd	s0,16(sp)
    80003f12:	e426                	sd	s1,8(sp)
    80003f14:	e04a                	sd	s2,0(sp)
    80003f16:	1000                	addi	s0,sp,32
    80003f18:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f1a:	00850913          	addi	s2,a0,8
    80003f1e:	854a                	mv	a0,s2
    80003f20:	ce5fc0ef          	jal	80000c04 <acquire>
  while (lk->locked) {
    80003f24:	409c                	lw	a5,0(s1)
    80003f26:	c799                	beqz	a5,80003f34 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f28:	85ca                	mv	a1,s2
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	fddfd0ef          	jal	80001f08 <sleep>
  while (lk->locked) {
    80003f30:	409c                	lw	a5,0(s1)
    80003f32:	fbfd                	bnez	a5,80003f28 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f34:	4785                	li	a5,1
    80003f36:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f38:	9cbfd0ef          	jal	80001902 <myproc>
    80003f3c:	591c                	lw	a5,48(a0)
    80003f3e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f40:	854a                	mv	a0,s2
    80003f42:	d53fc0ef          	jal	80000c94 <release>
}
    80003f46:	60e2                	ld	ra,24(sp)
    80003f48:	6442                	ld	s0,16(sp)
    80003f4a:	64a2                	ld	s1,8(sp)
    80003f4c:	6902                	ld	s2,0(sp)
    80003f4e:	6105                	addi	sp,sp,32
    80003f50:	8082                	ret

0000000080003f52 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f52:	1101                	addi	sp,sp,-32
    80003f54:	ec06                	sd	ra,24(sp)
    80003f56:	e822                	sd	s0,16(sp)
    80003f58:	e426                	sd	s1,8(sp)
    80003f5a:	e04a                	sd	s2,0(sp)
    80003f5c:	1000                	addi	s0,sp,32
    80003f5e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f60:	00850913          	addi	s2,a0,8
    80003f64:	854a                	mv	a0,s2
    80003f66:	c9ffc0ef          	jal	80000c04 <acquire>
  lk->locked = 0;
    80003f6a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f6e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f72:	8526                	mv	a0,s1
    80003f74:	fe1fd0ef          	jal	80001f54 <wakeup>
  release(&lk->lk);
    80003f78:	854a                	mv	a0,s2
    80003f7a:	d1bfc0ef          	jal	80000c94 <release>
}
    80003f7e:	60e2                	ld	ra,24(sp)
    80003f80:	6442                	ld	s0,16(sp)
    80003f82:	64a2                	ld	s1,8(sp)
    80003f84:	6902                	ld	s2,0(sp)
    80003f86:	6105                	addi	sp,sp,32
    80003f88:	8082                	ret

0000000080003f8a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f8a:	7179                	addi	sp,sp,-48
    80003f8c:	f406                	sd	ra,40(sp)
    80003f8e:	f022                	sd	s0,32(sp)
    80003f90:	ec26                	sd	s1,24(sp)
    80003f92:	e84a                	sd	s2,16(sp)
    80003f94:	1800                	addi	s0,sp,48
    80003f96:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80003f98:	00850913          	addi	s2,a0,8
    80003f9c:	854a                	mv	a0,s2
    80003f9e:	c67fc0ef          	jal	80000c04 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fa2:	409c                	lw	a5,0(s1)
    80003fa4:	ef81                	bnez	a5,80003fbc <holdingsleep+0x32>
    80003fa6:	4481                	li	s1,0
  release(&lk->lk);
    80003fa8:	854a                	mv	a0,s2
    80003faa:	cebfc0ef          	jal	80000c94 <release>
  return r;
}
    80003fae:	8526                	mv	a0,s1
    80003fb0:	70a2                	ld	ra,40(sp)
    80003fb2:	7402                	ld	s0,32(sp)
    80003fb4:	64e2                	ld	s1,24(sp)
    80003fb6:	6942                	ld	s2,16(sp)
    80003fb8:	6145                	addi	sp,sp,48
    80003fba:	8082                	ret
    80003fbc:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fbe:	0284a983          	lw	s3,40(s1)
    80003fc2:	941fd0ef          	jal	80001902 <myproc>
    80003fc6:	5904                	lw	s1,48(a0)
    80003fc8:	413484b3          	sub	s1,s1,s3
    80003fcc:	0014b493          	seqz	s1,s1
    80003fd0:	69a2                	ld	s3,8(sp)
    80003fd2:	bfd9                	j	80003fa8 <holdingsleep+0x1e>

0000000080003fd4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003fd4:	1141                	addi	sp,sp,-16
    80003fd6:	e406                	sd	ra,8(sp)
    80003fd8:	e022                	sd	s0,0(sp)
    80003fda:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003fdc:	00003597          	auipc	a1,0x3
    80003fe0:	57c58593          	addi	a1,a1,1404 # 80007558 <etext+0x558>
    80003fe4:	0001e517          	auipc	a0,0x1e
    80003fe8:	4dc50513          	addi	a0,a0,1244 # 800224c0 <ftable>
    80003fec:	b8ffc0ef          	jal	80000b7a <initlock>
}
    80003ff0:	60a2                	ld	ra,8(sp)
    80003ff2:	6402                	ld	s0,0(sp)
    80003ff4:	0141                	addi	sp,sp,16
    80003ff6:	8082                	ret

0000000080003ff8 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80003ff8:	1101                	addi	sp,sp,-32
    80003ffa:	ec06                	sd	ra,24(sp)
    80003ffc:	e822                	sd	s0,16(sp)
    80003ffe:	e426                	sd	s1,8(sp)
    80004000:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004002:	0001e517          	auipc	a0,0x1e
    80004006:	4be50513          	addi	a0,a0,1214 # 800224c0 <ftable>
    8000400a:	bfbfc0ef          	jal	80000c04 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    8000400e:	0001e497          	auipc	s1,0x1e
    80004012:	4ca48493          	addi	s1,s1,1226 # 800224d8 <ftable+0x18>
    80004016:	0001f717          	auipc	a4,0x1f
    8000401a:	46270713          	addi	a4,a4,1122 # 80023478 <disk>
    if (f->ref == 0) {
    8000401e:	40dc                	lw	a5,4(s1)
    80004020:	cf89                	beqz	a5,8000403a <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004022:	02848493          	addi	s1,s1,40
    80004026:	fee49ce3          	bne	s1,a4,8000401e <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000402a:	0001e517          	auipc	a0,0x1e
    8000402e:	49650513          	addi	a0,a0,1174 # 800224c0 <ftable>
    80004032:	c63fc0ef          	jal	80000c94 <release>
  return 0;
    80004036:	4481                	li	s1,0
    80004038:	a809                	j	8000404a <filealloc+0x52>
      f->ref = 1;
    8000403a:	4785                	li	a5,1
    8000403c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000403e:	0001e517          	auipc	a0,0x1e
    80004042:	48250513          	addi	a0,a0,1154 # 800224c0 <ftable>
    80004046:	c4ffc0ef          	jal	80000c94 <release>
}
    8000404a:	8526                	mv	a0,s1
    8000404c:	60e2                	ld	ra,24(sp)
    8000404e:	6442                	ld	s0,16(sp)
    80004050:	64a2                	ld	s1,8(sp)
    80004052:	6105                	addi	sp,sp,32
    80004054:	8082                	ret

0000000080004056 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004056:	1101                	addi	sp,sp,-32
    80004058:	ec06                	sd	ra,24(sp)
    8000405a:	e822                	sd	s0,16(sp)
    8000405c:	e426                	sd	s1,8(sp)
    8000405e:	1000                	addi	s0,sp,32
    80004060:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004062:	0001e517          	auipc	a0,0x1e
    80004066:	45e50513          	addi	a0,a0,1118 # 800224c0 <ftable>
    8000406a:	b9bfc0ef          	jal	80000c04 <acquire>
  if (f->ref < 1)
    8000406e:	40dc                	lw	a5,4(s1)
    80004070:	02f05063          	blez	a5,80004090 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004074:	2785                	addiw	a5,a5,1
    80004076:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004078:	0001e517          	auipc	a0,0x1e
    8000407c:	44850513          	addi	a0,a0,1096 # 800224c0 <ftable>
    80004080:	c15fc0ef          	jal	80000c94 <release>
  return f;
}
    80004084:	8526                	mv	a0,s1
    80004086:	60e2                	ld	ra,24(sp)
    80004088:	6442                	ld	s0,16(sp)
    8000408a:	64a2                	ld	s1,8(sp)
    8000408c:	6105                	addi	sp,sp,32
    8000408e:	8082                	ret
    panic("filedup");
    80004090:	00003517          	auipc	a0,0x3
    80004094:	4d050513          	addi	a0,a0,1232 # 80007560 <etext+0x560>
    80004098:	f80fc0ef          	jal	80000818 <panic>

000000008000409c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000409c:	7139                	addi	sp,sp,-64
    8000409e:	fc06                	sd	ra,56(sp)
    800040a0:	f822                	sd	s0,48(sp)
    800040a2:	f426                	sd	s1,40(sp)
    800040a4:	0080                	addi	s0,sp,64
    800040a6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040a8:	0001e517          	auipc	a0,0x1e
    800040ac:	41850513          	addi	a0,a0,1048 # 800224c0 <ftable>
    800040b0:	b55fc0ef          	jal	80000c04 <acquire>
  if (f->ref < 1)
    800040b4:	40dc                	lw	a5,4(s1)
    800040b6:	04f05a63          	blez	a5,8000410a <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800040ba:	37fd                	addiw	a5,a5,-1
    800040bc:	c0dc                	sw	a5,4(s1)
    800040be:	06f04063          	bgtz	a5,8000411e <fileclose+0x82>
    800040c2:	f04a                	sd	s2,32(sp)
    800040c4:	ec4e                	sd	s3,24(sp)
    800040c6:	e852                	sd	s4,16(sp)
    800040c8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800040ca:	0004a903          	lw	s2,0(s1)
    800040ce:	0094c783          	lbu	a5,9(s1)
    800040d2:	89be                	mv	s3,a5
    800040d4:	689c                	ld	a5,16(s1)
    800040d6:	8a3e                	mv	s4,a5
    800040d8:	6c9c                	ld	a5,24(s1)
    800040da:	8abe                	mv	s5,a5
  f->ref = 0;
    800040dc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800040e0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800040e4:	0001e517          	auipc	a0,0x1e
    800040e8:	3dc50513          	addi	a0,a0,988 # 800224c0 <ftable>
    800040ec:	ba9fc0ef          	jal	80000c94 <release>

  if (ff.type == FD_PIPE) {
    800040f0:	4785                	li	a5,1
    800040f2:	04f90163          	beq	s2,a5,80004134 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800040f6:	ffe9079b          	addiw	a5,s2,-2
    800040fa:	4705                	li	a4,1
    800040fc:	04f77563          	bgeu	a4,a5,80004146 <fileclose+0xaa>
    80004100:	7902                	ld	s2,32(sp)
    80004102:	69e2                	ld	s3,24(sp)
    80004104:	6a42                	ld	s4,16(sp)
    80004106:	6aa2                	ld	s5,8(sp)
    80004108:	a00d                	j	8000412a <fileclose+0x8e>
    8000410a:	f04a                	sd	s2,32(sp)
    8000410c:	ec4e                	sd	s3,24(sp)
    8000410e:	e852                	sd	s4,16(sp)
    80004110:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004112:	00003517          	auipc	a0,0x3
    80004116:	45650513          	addi	a0,a0,1110 # 80007568 <etext+0x568>
    8000411a:	efefc0ef          	jal	80000818 <panic>
    release(&ftable.lock);
    8000411e:	0001e517          	auipc	a0,0x1e
    80004122:	3a250513          	addi	a0,a0,930 # 800224c0 <ftable>
    80004126:	b6ffc0ef          	jal	80000c94 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000412a:	70e2                	ld	ra,56(sp)
    8000412c:	7442                	ld	s0,48(sp)
    8000412e:	74a2                	ld	s1,40(sp)
    80004130:	6121                	addi	sp,sp,64
    80004132:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004134:	85ce                	mv	a1,s3
    80004136:	8552                	mv	a0,s4
    80004138:	348000ef          	jal	80004480 <pipeclose>
    8000413c:	7902                	ld	s2,32(sp)
    8000413e:	69e2                	ld	s3,24(sp)
    80004140:	6a42                	ld	s4,16(sp)
    80004142:	6aa2                	ld	s5,8(sp)
    80004144:	b7dd                	j	8000412a <fileclose+0x8e>
    begin_op();
    80004146:	ad5ff0ef          	jal	80003c1a <begin_op>
    iput(ff.ip);
    8000414a:	8556                	mv	a0,s5
    8000414c:	a44ff0ef          	jal	80003390 <iput>
    end_op();
    80004150:	b3bff0ef          	jal	80003c8a <end_op>
    80004154:	7902                	ld	s2,32(sp)
    80004156:	69e2                	ld	s3,24(sp)
    80004158:	6a42                	ld	s4,16(sp)
    8000415a:	6aa2                	ld	s5,8(sp)
    8000415c:	b7f9                	j	8000412a <fileclose+0x8e>

000000008000415e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000415e:	715d                	addi	sp,sp,-80
    80004160:	e486                	sd	ra,72(sp)
    80004162:	e0a2                	sd	s0,64(sp)
    80004164:	fc26                	sd	s1,56(sp)
    80004166:	f052                	sd	s4,32(sp)
    80004168:	0880                	addi	s0,sp,80
    8000416a:	84aa                	mv	s1,a0
    8000416c:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000416e:	f94fd0ef          	jal	80001902 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004172:	409c                	lw	a5,0(s1)
    80004174:	37f9                	addiw	a5,a5,-2
    80004176:	4705                	li	a4,1
    80004178:	04f76263          	bltu	a4,a5,800041bc <filestat+0x5e>
    8000417c:	f84a                	sd	s2,48(sp)
    8000417e:	f44e                	sd	s3,40(sp)
    80004180:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004182:	6c88                	ld	a0,24(s1)
    80004184:	88aff0ef          	jal	8000320e <ilock>
    stati(f->ip, &st);
    80004188:	fb840913          	addi	s2,s0,-72
    8000418c:	85ca                	mv	a1,s2
    8000418e:	6c88                	ld	a0,24(s1)
    80004190:	be2ff0ef          	jal	80003572 <stati>
    iunlock(f->ip);
    80004194:	6c88                	ld	a0,24(s1)
    80004196:	926ff0ef          	jal	800032bc <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000419a:	46e1                	li	a3,24
    8000419c:	864a                	mv	a2,s2
    8000419e:	85d2                	mv	a1,s4
    800041a0:	0509b503          	ld	a0,80(s3)
    800041a4:	c84fd0ef          	jal	80001628 <copyout>
    800041a8:	41f5551b          	sraiw	a0,a0,0x1f
    800041ac:	7942                	ld	s2,48(sp)
    800041ae:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800041b0:	60a6                	ld	ra,72(sp)
    800041b2:	6406                	ld	s0,64(sp)
    800041b4:	74e2                	ld	s1,56(sp)
    800041b6:	7a02                	ld	s4,32(sp)
    800041b8:	6161                	addi	sp,sp,80
    800041ba:	8082                	ret
  return -1;
    800041bc:	557d                	li	a0,-1
    800041be:	bfcd                	j	800041b0 <filestat+0x52>

00000000800041c0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041c0:	7179                	addi	sp,sp,-48
    800041c2:	f406                	sd	ra,40(sp)
    800041c4:	f022                	sd	s0,32(sp)
    800041c6:	e84a                	sd	s2,16(sp)
    800041c8:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    800041ca:	00854783          	lbu	a5,8(a0)
    800041ce:	cfd1                	beqz	a5,8000426a <fileread+0xaa>
    800041d0:	ec26                	sd	s1,24(sp)
    800041d2:	e44e                	sd	s3,8(sp)
    800041d4:	84aa                	mv	s1,a0
    800041d6:	892e                	mv	s2,a1
    800041d8:	89b2                	mv	s3,a2
    return -1;

  if (f->type == FD_PIPE) {
    800041da:	411c                	lw	a5,0(a0)
    800041dc:	4705                	li	a4,1
    800041de:	04e78363          	beq	a5,a4,80004224 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800041e2:	470d                	li	a4,3
    800041e4:	04e78763          	beq	a5,a4,80004232 <fileread+0x72>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800041e8:	4709                	li	a4,2
    800041ea:	06e79a63          	bne	a5,a4,8000425e <fileread+0x9e>
    ilock(f->ip);
    800041ee:	6d08                	ld	a0,24(a0)
    800041f0:	81eff0ef          	jal	8000320e <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800041f4:	874e                	mv	a4,s3
    800041f6:	5094                	lw	a3,32(s1)
    800041f8:	864a                	mv	a2,s2
    800041fa:	4585                	li	a1,1
    800041fc:	6c88                	ld	a0,24(s1)
    800041fe:	ba2ff0ef          	jal	800035a0 <readi>
    80004202:	892a                	mv	s2,a0
    80004204:	00a05563          	blez	a0,8000420e <fileread+0x4e>
      f->off += r;
    80004208:	509c                	lw	a5,32(s1)
    8000420a:	9fa9                	addw	a5,a5,a0
    8000420c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000420e:	6c88                	ld	a0,24(s1)
    80004210:	8acff0ef          	jal	800032bc <iunlock>
    80004214:	64e2                	ld	s1,24(sp)
    80004216:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004218:	854a                	mv	a0,s2
    8000421a:	70a2                	ld	ra,40(sp)
    8000421c:	7402                	ld	s0,32(sp)
    8000421e:	6942                	ld	s2,16(sp)
    80004220:	6145                	addi	sp,sp,48
    80004222:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004224:	6908                	ld	a0,16(a0)
    80004226:	3b0000ef          	jal	800045d6 <piperead>
    8000422a:	892a                	mv	s2,a0
    8000422c:	64e2                	ld	s1,24(sp)
    8000422e:	69a2                	ld	s3,8(sp)
    80004230:	b7e5                	j	80004218 <fileread+0x58>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004232:	02451783          	lh	a5,36(a0)
    80004236:	03079693          	slli	a3,a5,0x30
    8000423a:	92c1                	srli	a3,a3,0x30
    8000423c:	4725                	li	a4,9
    8000423e:	02d76963          	bltu	a4,a3,80004270 <fileread+0xb0>
    80004242:	0792                	slli	a5,a5,0x4
    80004244:	0001e717          	auipc	a4,0x1e
    80004248:	1dc70713          	addi	a4,a4,476 # 80022420 <devsw>
    8000424c:	97ba                	add	a5,a5,a4
    8000424e:	639c                	ld	a5,0(a5)
    80004250:	c78d                	beqz	a5,8000427a <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004252:	4505                	li	a0,1
    80004254:	9782                	jalr	a5
    80004256:	892a                	mv	s2,a0
    80004258:	64e2                	ld	s1,24(sp)
    8000425a:	69a2                	ld	s3,8(sp)
    8000425c:	bf75                	j	80004218 <fileread+0x58>
    panic("fileread");
    8000425e:	00003517          	auipc	a0,0x3
    80004262:	31a50513          	addi	a0,a0,794 # 80007578 <etext+0x578>
    80004266:	db2fc0ef          	jal	80000818 <panic>
    return -1;
    8000426a:	57fd                	li	a5,-1
    8000426c:	893e                	mv	s2,a5
    8000426e:	b76d                	j	80004218 <fileread+0x58>
      return -1;
    80004270:	57fd                	li	a5,-1
    80004272:	893e                	mv	s2,a5
    80004274:	64e2                	ld	s1,24(sp)
    80004276:	69a2                	ld	s3,8(sp)
    80004278:	b745                	j	80004218 <fileread+0x58>
    8000427a:	57fd                	li	a5,-1
    8000427c:	893e                	mv	s2,a5
    8000427e:	64e2                	ld	s1,24(sp)
    80004280:	69a2                	ld	s3,8(sp)
    80004282:	bf59                	j	80004218 <fileread+0x58>

0000000080004284 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0)
    80004284:	00954783          	lbu	a5,9(a0)
    80004288:	10078f63          	beqz	a5,800043a6 <filewrite+0x122>
{
    8000428c:	711d                	addi	sp,sp,-96
    8000428e:	ec86                	sd	ra,88(sp)
    80004290:	e8a2                	sd	s0,80(sp)
    80004292:	e0ca                	sd	s2,64(sp)
    80004294:	f456                	sd	s5,40(sp)
    80004296:	f05a                	sd	s6,32(sp)
    80004298:	1080                	addi	s0,sp,96
    8000429a:	892a                	mv	s2,a0
    8000429c:	8b2e                	mv	s6,a1
    8000429e:	8ab2                	mv	s5,a2
    return -1;

  if (f->type == FD_PIPE) {
    800042a0:	411c                	lw	a5,0(a0)
    800042a2:	4705                	li	a4,1
    800042a4:	02e78a63          	beq	a5,a4,800042d8 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800042a8:	470d                	li	a4,3
    800042aa:	02e78b63          	beq	a5,a4,800042e0 <filewrite+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800042ae:	4709                	li	a4,2
    800042b0:	0ce79f63          	bne	a5,a4,8000438e <filewrite+0x10a>
    800042b4:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800042b6:	0ac05a63          	blez	a2,8000436a <filewrite+0xe6>
    800042ba:	e4a6                	sd	s1,72(sp)
    800042bc:	fc4e                	sd	s3,56(sp)
    800042be:	ec5e                	sd	s7,24(sp)
    800042c0:	e862                	sd	s8,16(sp)
    800042c2:	e466                	sd	s9,8(sp)
    int i = 0;
    800042c4:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800042c6:	6b85                	lui	s7,0x1
    800042c8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800042cc:	6785                	lui	a5,0x1
    800042ce:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800042d2:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800042d4:	4c05                	li	s8,1
    800042d6:	a8ad                	j	80004350 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800042d8:	6908                	ld	a0,16(a0)
    800042da:	204000ef          	jal	800044de <pipewrite>
    800042de:	a04d                	j	80004380 <filewrite+0xfc>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800042e0:	02451783          	lh	a5,36(a0)
    800042e4:	03079693          	slli	a3,a5,0x30
    800042e8:	92c1                	srli	a3,a3,0x30
    800042ea:	4725                	li	a4,9
    800042ec:	0ad76f63          	bltu	a4,a3,800043aa <filewrite+0x126>
    800042f0:	0792                	slli	a5,a5,0x4
    800042f2:	0001e717          	auipc	a4,0x1e
    800042f6:	12e70713          	addi	a4,a4,302 # 80022420 <devsw>
    800042fa:	97ba                	add	a5,a5,a4
    800042fc:	679c                	ld	a5,8(a5)
    800042fe:	cbc5                	beqz	a5,800043ae <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004300:	4505                	li	a0,1
    80004302:	9782                	jalr	a5
    80004304:	a8b5                	j	80004380 <filewrite+0xfc>
      if (n1 > max)
    80004306:	2981                	sext.w	s3,s3
      begin_op();
    80004308:	913ff0ef          	jal	80003c1a <begin_op>
      ilock(f->ip);
    8000430c:	01893503          	ld	a0,24(s2)
    80004310:	efffe0ef          	jal	8000320e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004314:	874e                	mv	a4,s3
    80004316:	02092683          	lw	a3,32(s2)
    8000431a:	016a0633          	add	a2,s4,s6
    8000431e:	85e2                	mv	a1,s8
    80004320:	01893503          	ld	a0,24(s2)
    80004324:	b6eff0ef          	jal	80003692 <writei>
    80004328:	84aa                	mv	s1,a0
    8000432a:	00a05763          	blez	a0,80004338 <filewrite+0xb4>
        f->off += r;
    8000432e:	02092783          	lw	a5,32(s2)
    80004332:	9fa9                	addw	a5,a5,a0
    80004334:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004338:	01893503          	ld	a0,24(s2)
    8000433c:	f81fe0ef          	jal	800032bc <iunlock>
      end_op();
    80004340:	94bff0ef          	jal	80003c8a <end_op>

      if (r != n1) {
    80004344:	02999563          	bne	s3,s1,8000436e <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004348:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    8000434c:	015a5963          	bge	s4,s5,8000435e <filewrite+0xda>
      int n1 = n - i;
    80004350:	414a87bb          	subw	a5,s5,s4
    80004354:	89be                	mv	s3,a5
      if (n1 > max)
    80004356:	fafbd8e3          	bge	s7,a5,80004306 <filewrite+0x82>
    8000435a:	89e6                	mv	s3,s9
    8000435c:	b76d                	j	80004306 <filewrite+0x82>
    8000435e:	64a6                	ld	s1,72(sp)
    80004360:	79e2                	ld	s3,56(sp)
    80004362:	6be2                	ld	s7,24(sp)
    80004364:	6c42                	ld	s8,16(sp)
    80004366:	6ca2                	ld	s9,8(sp)
    80004368:	a801                	j	80004378 <filewrite+0xf4>
    int i = 0;
    8000436a:	4a01                	li	s4,0
    8000436c:	a031                	j	80004378 <filewrite+0xf4>
    8000436e:	64a6                	ld	s1,72(sp)
    80004370:	79e2                	ld	s3,56(sp)
    80004372:	6be2                	ld	s7,24(sp)
    80004374:	6c42                	ld	s8,16(sp)
    80004376:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004378:	034a9d63          	bne	s5,s4,800043b2 <filewrite+0x12e>
    8000437c:	8556                	mv	a0,s5
    8000437e:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004380:	60e6                	ld	ra,88(sp)
    80004382:	6446                	ld	s0,80(sp)
    80004384:	6906                	ld	s2,64(sp)
    80004386:	7aa2                	ld	s5,40(sp)
    80004388:	7b02                	ld	s6,32(sp)
    8000438a:	6125                	addi	sp,sp,96
    8000438c:	8082                	ret
    8000438e:	e4a6                	sd	s1,72(sp)
    80004390:	fc4e                	sd	s3,56(sp)
    80004392:	f852                	sd	s4,48(sp)
    80004394:	ec5e                	sd	s7,24(sp)
    80004396:	e862                	sd	s8,16(sp)
    80004398:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000439a:	00003517          	auipc	a0,0x3
    8000439e:	1ee50513          	addi	a0,a0,494 # 80007588 <etext+0x588>
    800043a2:	c76fc0ef          	jal	80000818 <panic>
    return -1;
    800043a6:	557d                	li	a0,-1
}
    800043a8:	8082                	ret
      return -1;
    800043aa:	557d                	li	a0,-1
    800043ac:	bfd1                	j	80004380 <filewrite+0xfc>
    800043ae:	557d                	li	a0,-1
    800043b0:	bfc1                	j	80004380 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800043b2:	557d                	li	a0,-1
    800043b4:	7a42                	ld	s4,48(sp)
    800043b6:	b7e9                	j	80004380 <filewrite+0xfc>

00000000800043b8 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800043b8:	7179                	addi	sp,sp,-48
    800043ba:	f406                	sd	ra,40(sp)
    800043bc:	f022                	sd	s0,32(sp)
    800043be:	ec26                	sd	s1,24(sp)
    800043c0:	e052                	sd	s4,0(sp)
    800043c2:	1800                	addi	s0,sp,48
    800043c4:	84aa                	mv	s1,a0
    800043c6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043c8:	0005b023          	sd	zero,0(a1)
    800043cc:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043d0:	c29ff0ef          	jal	80003ff8 <filealloc>
    800043d4:	e088                	sd	a0,0(s1)
    800043d6:	c549                	beqz	a0,80004460 <pipealloc+0xa8>
    800043d8:	c21ff0ef          	jal	80003ff8 <filealloc>
    800043dc:	00aa3023          	sd	a0,0(s4)
    800043e0:	cd25                	beqz	a0,80004458 <pipealloc+0xa0>
    800043e2:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800043e4:	f3cfc0ef          	jal	80000b20 <kalloc>
    800043e8:	892a                	mv	s2,a0
    800043ea:	c12d                	beqz	a0,8000444c <pipealloc+0x94>
    800043ec:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800043ee:	4985                	li	s3,1
    800043f0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800043f4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800043f8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800043fc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004400:	00003597          	auipc	a1,0x3
    80004404:	19858593          	addi	a1,a1,408 # 80007598 <etext+0x598>
    80004408:	f72fc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    8000440c:	609c                	ld	a5,0(s1)
    8000440e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004412:	609c                	ld	a5,0(s1)
    80004414:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004418:	609c                	ld	a5,0(s1)
    8000441a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000441e:	609c                	ld	a5,0(s1)
    80004420:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004424:	000a3783          	ld	a5,0(s4)
    80004428:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000442c:	000a3783          	ld	a5,0(s4)
    80004430:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004434:	000a3783          	ld	a5,0(s4)
    80004438:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000443c:	000a3783          	ld	a5,0(s4)
    80004440:	0127b823          	sd	s2,16(a5)
  return 0;
    80004444:	4501                	li	a0,0
    80004446:	6942                	ld	s2,16(sp)
    80004448:	69a2                	ld	s3,8(sp)
    8000444a:	a01d                	j	80004470 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    8000444c:	6088                	ld	a0,0(s1)
    8000444e:	c119                	beqz	a0,80004454 <pipealloc+0x9c>
    80004450:	6942                	ld	s2,16(sp)
    80004452:	a029                	j	8000445c <pipealloc+0xa4>
    80004454:	6942                	ld	s2,16(sp)
    80004456:	a029                	j	80004460 <pipealloc+0xa8>
    80004458:	6088                	ld	a0,0(s1)
    8000445a:	c10d                	beqz	a0,8000447c <pipealloc+0xc4>
    fileclose(*f0);
    8000445c:	c41ff0ef          	jal	8000409c <fileclose>
  if (*f1)
    80004460:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004464:	557d                	li	a0,-1
  if (*f1)
    80004466:	c789                	beqz	a5,80004470 <pipealloc+0xb8>
    fileclose(*f1);
    80004468:	853e                	mv	a0,a5
    8000446a:	c33ff0ef          	jal	8000409c <fileclose>
  return -1;
    8000446e:	557d                	li	a0,-1
}
    80004470:	70a2                	ld	ra,40(sp)
    80004472:	7402                	ld	s0,32(sp)
    80004474:	64e2                	ld	s1,24(sp)
    80004476:	6a02                	ld	s4,0(sp)
    80004478:	6145                	addi	sp,sp,48
    8000447a:	8082                	ret
  return -1;
    8000447c:	557d                	li	a0,-1
    8000447e:	bfcd                	j	80004470 <pipealloc+0xb8>

0000000080004480 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004480:	1101                	addi	sp,sp,-32
    80004482:	ec06                	sd	ra,24(sp)
    80004484:	e822                	sd	s0,16(sp)
    80004486:	e426                	sd	s1,8(sp)
    80004488:	e04a                	sd	s2,0(sp)
    8000448a:	1000                	addi	s0,sp,32
    8000448c:	84aa                	mv	s1,a0
    8000448e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004490:	f74fc0ef          	jal	80000c04 <acquire>
  if (writable) {
    80004494:	02090763          	beqz	s2,800044c2 <pipeclose+0x42>
    pi->writeopen = 0;
    80004498:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000449c:	21848513          	addi	a0,s1,536
    800044a0:	ab5fd0ef          	jal	80001f54 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800044a4:	2204a783          	lw	a5,544(s1)
    800044a8:	e781                	bnez	a5,800044b0 <pipeclose+0x30>
    800044aa:	2244a783          	lw	a5,548(s1)
    800044ae:	c38d                	beqz	a5,800044d0 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    800044b0:	8526                	mv	a0,s1
    800044b2:	fe2fc0ef          	jal	80000c94 <release>
}
    800044b6:	60e2                	ld	ra,24(sp)
    800044b8:	6442                	ld	s0,16(sp)
    800044ba:	64a2                	ld	s1,8(sp)
    800044bc:	6902                	ld	s2,0(sp)
    800044be:	6105                	addi	sp,sp,32
    800044c0:	8082                	ret
    pi->readopen = 0;
    800044c2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044c6:	21c48513          	addi	a0,s1,540
    800044ca:	a8bfd0ef          	jal	80001f54 <wakeup>
    800044ce:	bfd9                	j	800044a4 <pipeclose+0x24>
    release(&pi->lock);
    800044d0:	8526                	mv	a0,s1
    800044d2:	fc2fc0ef          	jal	80000c94 <release>
    kfree((char *)pi);
    800044d6:	8526                	mv	a0,s1
    800044d8:	d60fc0ef          	jal	80000a38 <kfree>
    800044dc:	bfe9                	j	800044b6 <pipeclose+0x36>

00000000800044de <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800044de:	7159                	addi	sp,sp,-112
    800044e0:	f486                	sd	ra,104(sp)
    800044e2:	f0a2                	sd	s0,96(sp)
    800044e4:	eca6                	sd	s1,88(sp)
    800044e6:	e8ca                	sd	s2,80(sp)
    800044e8:	e4ce                	sd	s3,72(sp)
    800044ea:	e0d2                	sd	s4,64(sp)
    800044ec:	fc56                	sd	s5,56(sp)
    800044ee:	1880                	addi	s0,sp,112
    800044f0:	84aa                	mv	s1,a0
    800044f2:	8aae                	mv	s5,a1
    800044f4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800044f6:	c0cfd0ef          	jal	80001902 <myproc>
    800044fa:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800044fc:	8526                	mv	a0,s1
    800044fe:	f06fc0ef          	jal	80000c04 <acquire>
  while (i < n) {
    80004502:	0d405263          	blez	s4,800045c6 <pipewrite+0xe8>
    80004506:	f85a                	sd	s6,48(sp)
    80004508:	f45e                	sd	s7,40(sp)
    8000450a:	f062                	sd	s8,32(sp)
    8000450c:	ec66                	sd	s9,24(sp)
    8000450e:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004510:	4901                	li	s2,0
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004512:	f9f40c13          	addi	s8,s0,-97
    80004516:	4b85                	li	s7,1
    80004518:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000451a:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000451e:	21c48c93          	addi	s9,s1,540
    80004522:	a82d                	j	8000455c <pipewrite+0x7e>
      release(&pi->lock);
    80004524:	8526                	mv	a0,s1
    80004526:	f6efc0ef          	jal	80000c94 <release>
      return -1;
    8000452a:	597d                	li	s2,-1
    8000452c:	7b42                	ld	s6,48(sp)
    8000452e:	7ba2                	ld	s7,40(sp)
    80004530:	7c02                	ld	s8,32(sp)
    80004532:	6ce2                	ld	s9,24(sp)
    80004534:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004536:	854a                	mv	a0,s2
    80004538:	70a6                	ld	ra,104(sp)
    8000453a:	7406                	ld	s0,96(sp)
    8000453c:	64e6                	ld	s1,88(sp)
    8000453e:	6946                	ld	s2,80(sp)
    80004540:	69a6                	ld	s3,72(sp)
    80004542:	6a06                	ld	s4,64(sp)
    80004544:	7ae2                	ld	s5,56(sp)
    80004546:	6165                	addi	sp,sp,112
    80004548:	8082                	ret
      wakeup(&pi->nread);
    8000454a:	856a                	mv	a0,s10
    8000454c:	a09fd0ef          	jal	80001f54 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004550:	85a6                	mv	a1,s1
    80004552:	8566                	mv	a0,s9
    80004554:	9b5fd0ef          	jal	80001f08 <sleep>
  while (i < n) {
    80004558:	05495a63          	bge	s2,s4,800045ac <pipewrite+0xce>
    if (pi->readopen == 0 || killed(pr)) {
    8000455c:	2204a783          	lw	a5,544(s1)
    80004560:	d3f1                	beqz	a5,80004524 <pipewrite+0x46>
    80004562:	854e                	mv	a0,s3
    80004564:	be1fd0ef          	jal	80002144 <killed>
    80004568:	fd55                	bnez	a0,80004524 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000456a:	2184a783          	lw	a5,536(s1)
    8000456e:	21c4a703          	lw	a4,540(s1)
    80004572:	2007879b          	addiw	a5,a5,512
    80004576:	fcf70ae3          	beq	a4,a5,8000454a <pipewrite+0x6c>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000457a:	86de                	mv	a3,s7
    8000457c:	01590633          	add	a2,s2,s5
    80004580:	85e2                	mv	a1,s8
    80004582:	0509b503          	ld	a0,80(s3)
    80004586:	960fd0ef          	jal	800016e6 <copyin>
    8000458a:	05650063          	beq	a0,s6,800045ca <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000458e:	21c4a783          	lw	a5,540(s1)
    80004592:	0017871b          	addiw	a4,a5,1
    80004596:	20e4ae23          	sw	a4,540(s1)
    8000459a:	1ff7f793          	andi	a5,a5,511
    8000459e:	97a6                	add	a5,a5,s1
    800045a0:	f9f44703          	lbu	a4,-97(s0)
    800045a4:	00e78c23          	sb	a4,24(a5)
      i++;
    800045a8:	2905                	addiw	s2,s2,1
    800045aa:	b77d                	j	80004558 <pipewrite+0x7a>
    800045ac:	7b42                	ld	s6,48(sp)
    800045ae:	7ba2                	ld	s7,40(sp)
    800045b0:	7c02                	ld	s8,32(sp)
    800045b2:	6ce2                	ld	s9,24(sp)
    800045b4:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800045b6:	21848513          	addi	a0,s1,536
    800045ba:	99bfd0ef          	jal	80001f54 <wakeup>
  release(&pi->lock);
    800045be:	8526                	mv	a0,s1
    800045c0:	ed4fc0ef          	jal	80000c94 <release>
  return i;
    800045c4:	bf8d                	j	80004536 <pipewrite+0x58>
  int i = 0;
    800045c6:	4901                	li	s2,0
    800045c8:	b7fd                	j	800045b6 <pipewrite+0xd8>
    800045ca:	7b42                	ld	s6,48(sp)
    800045cc:	7ba2                	ld	s7,40(sp)
    800045ce:	7c02                	ld	s8,32(sp)
    800045d0:	6ce2                	ld	s9,24(sp)
    800045d2:	6d42                	ld	s10,16(sp)
    800045d4:	b7cd                	j	800045b6 <pipewrite+0xd8>

00000000800045d6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045d6:	711d                	addi	sp,sp,-96
    800045d8:	ec86                	sd	ra,88(sp)
    800045da:	e8a2                	sd	s0,80(sp)
    800045dc:	e4a6                	sd	s1,72(sp)
    800045de:	e0ca                	sd	s2,64(sp)
    800045e0:	fc4e                	sd	s3,56(sp)
    800045e2:	f852                	sd	s4,48(sp)
    800045e4:	f456                	sd	s5,40(sp)
    800045e6:	1080                	addi	s0,sp,96
    800045e8:	84aa                	mv	s1,a0
    800045ea:	892e                	mv	s2,a1
    800045ec:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800045ee:	b14fd0ef          	jal	80001902 <myproc>
    800045f2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800045f4:	8526                	mv	a0,s1
    800045f6:	e0efc0ef          	jal	80000c04 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800045fa:	2184a703          	lw	a4,536(s1)
    800045fe:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004602:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004606:	02f71763          	bne	a4,a5,80004634 <piperead+0x5e>
    8000460a:	2244a783          	lw	a5,548(s1)
    8000460e:	cf85                	beqz	a5,80004646 <piperead+0x70>
    if (killed(pr)) {
    80004610:	8552                	mv	a0,s4
    80004612:	b33fd0ef          	jal	80002144 <killed>
    80004616:	e11d                	bnez	a0,8000463c <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004618:	85a6                	mv	a1,s1
    8000461a:	854e                	mv	a0,s3
    8000461c:	8edfd0ef          	jal	80001f08 <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004620:	2184a703          	lw	a4,536(s1)
    80004624:	21c4a783          	lw	a5,540(s1)
    80004628:	fef701e3          	beq	a4,a5,8000460a <piperead+0x34>
    8000462c:	f05a                	sd	s6,32(sp)
    8000462e:	ec5e                	sd	s7,24(sp)
    80004630:	e862                	sd	s8,16(sp)
    80004632:	a829                	j	8000464c <piperead+0x76>
    80004634:	f05a                	sd	s6,32(sp)
    80004636:	ec5e                	sd	s7,24(sp)
    80004638:	e862                	sd	s8,16(sp)
    8000463a:	a809                	j	8000464c <piperead+0x76>
      release(&pi->lock);
    8000463c:	8526                	mv	a0,s1
    8000463e:	e56fc0ef          	jal	80000c94 <release>
      return -1;
    80004642:	59fd                	li	s3,-1
    80004644:	a0a5                	j	800046ac <piperead+0xd6>
    80004646:	f05a                	sd	s6,32(sp)
    80004648:	ec5e                	sd	s7,24(sp)
    8000464a:	e862                	sd	s8,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000464c:	4981                	li	s3,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000464e:	faf40c13          	addi	s8,s0,-81
    80004652:	4b85                	li	s7,1
    80004654:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004656:	05505163          	blez	s5,80004698 <piperead+0xc2>
    if (pi->nread == pi->nwrite)
    8000465a:	2184a783          	lw	a5,536(s1)
    8000465e:	21c4a703          	lw	a4,540(s1)
    80004662:	02f70b63          	beq	a4,a5,80004698 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004666:	1ff7f793          	andi	a5,a5,511
    8000466a:	97a6                	add	a5,a5,s1
    8000466c:	0187c783          	lbu	a5,24(a5)
    80004670:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004674:	86de                	mv	a3,s7
    80004676:	8662                	mv	a2,s8
    80004678:	85ca                	mv	a1,s2
    8000467a:	050a3503          	ld	a0,80(s4)
    8000467e:	fabfc0ef          	jal	80001628 <copyout>
    80004682:	03650f63          	beq	a0,s6,800046c0 <piperead+0xea>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004686:	2184a783          	lw	a5,536(s1)
    8000468a:	2785                	addiw	a5,a5,1
    8000468c:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004690:	2985                	addiw	s3,s3,1
    80004692:	0905                	addi	s2,s2,1
    80004694:	fd3a93e3          	bne	s5,s3,8000465a <piperead+0x84>
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004698:	21c48513          	addi	a0,s1,540
    8000469c:	8b9fd0ef          	jal	80001f54 <wakeup>
  release(&pi->lock);
    800046a0:	8526                	mv	a0,s1
    800046a2:	df2fc0ef          	jal	80000c94 <release>
    800046a6:	7b02                	ld	s6,32(sp)
    800046a8:	6be2                	ld	s7,24(sp)
    800046aa:	6c42                	ld	s8,16(sp)
  return i;
}
    800046ac:	854e                	mv	a0,s3
    800046ae:	60e6                	ld	ra,88(sp)
    800046b0:	6446                	ld	s0,80(sp)
    800046b2:	64a6                	ld	s1,72(sp)
    800046b4:	6906                	ld	s2,64(sp)
    800046b6:	79e2                	ld	s3,56(sp)
    800046b8:	7a42                	ld	s4,48(sp)
    800046ba:	7aa2                	ld	s5,40(sp)
    800046bc:	6125                	addi	sp,sp,96
    800046be:	8082                	ret
      if (i == 0)
    800046c0:	fc099ce3          	bnez	s3,80004698 <piperead+0xc2>
        i = -1;
    800046c4:	89aa                	mv	s3,a0
    800046c6:	bfc9                	j	80004698 <piperead+0xc2>

00000000800046c8 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800046c8:	1141                	addi	sp,sp,-16
    800046ca:	e406                	sd	ra,8(sp)
    800046cc:	e022                	sd	s0,0(sp)
    800046ce:	0800                	addi	s0,sp,16
    800046d0:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800046d2:	0035151b          	slliw	a0,a0,0x3
    800046d6:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800046d8:	8b89                	andi	a5,a5,2
    800046da:	c399                	beqz	a5,800046e0 <flags2perm+0x18>
    perm |= PTE_W;
    800046dc:	00456513          	ori	a0,a0,4
  return perm;
}
    800046e0:	60a2                	ld	ra,8(sp)
    800046e2:	6402                	ld	s0,0(sp)
    800046e4:	0141                	addi	sp,sp,16
    800046e6:	8082                	ret

00000000800046e8 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800046e8:	de010113          	addi	sp,sp,-544
    800046ec:	20113c23          	sd	ra,536(sp)
    800046f0:	20813823          	sd	s0,528(sp)
    800046f4:	20913423          	sd	s1,520(sp)
    800046f8:	21213023          	sd	s2,512(sp)
    800046fc:	1400                	addi	s0,sp,544
    800046fe:	892a                	mv	s2,a0
    80004700:	dea43823          	sd	a0,-528(s0)
    80004704:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004708:	9fafd0ef          	jal	80001902 <myproc>
    8000470c:	84aa                	mv	s1,a0

  begin_op();
    8000470e:	d0cff0ef          	jal	80003c1a <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004712:	854a                	mv	a0,s2
    80004714:	b28ff0ef          	jal	80003a3c <namei>
    80004718:	cd21                	beqz	a0,80004770 <kexec+0x88>
    8000471a:	fbd2                	sd	s4,496(sp)
    8000471c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000471e:	af1fe0ef          	jal	8000320e <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004722:	04000713          	li	a4,64
    80004726:	4681                	li	a3,0
    80004728:	e5040613          	addi	a2,s0,-432
    8000472c:	4581                	li	a1,0
    8000472e:	8552                	mv	a0,s4
    80004730:	e71fe0ef          	jal	800035a0 <readi>
    80004734:	04000793          	li	a5,64
    80004738:	00f51a63          	bne	a0,a5,8000474c <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    8000473c:	e5042703          	lw	a4,-432(s0)
    80004740:	464c47b7          	lui	a5,0x464c4
    80004744:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004748:	02f70863          	beq	a4,a5,80004778 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    8000474c:	8552                	mv	a0,s4
    8000474e:	ccdfe0ef          	jal	8000341a <iunlockput>
    end_op();
    80004752:	d38ff0ef          	jal	80003c8a <end_op>
  }
  return -1;
    80004756:	557d                	li	a0,-1
    80004758:	7a5e                	ld	s4,496(sp)
}
    8000475a:	21813083          	ld	ra,536(sp)
    8000475e:	21013403          	ld	s0,528(sp)
    80004762:	20813483          	ld	s1,520(sp)
    80004766:	20013903          	ld	s2,512(sp)
    8000476a:	22010113          	addi	sp,sp,544
    8000476e:	8082                	ret
    end_op();
    80004770:	d1aff0ef          	jal	80003c8a <end_op>
    return -1;
    80004774:	557d                	li	a0,-1
    80004776:	b7d5                	j	8000475a <kexec+0x72>
    80004778:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    8000477a:	8526                	mv	a0,s1
    8000477c:	a90fd0ef          	jal	80001a0c <proc_pagetable>
    80004780:	8b2a                	mv	s6,a0
    80004782:	26050f63          	beqz	a0,80004a00 <kexec+0x318>
    80004786:	ffce                	sd	s3,504(sp)
    80004788:	f7d6                	sd	s5,488(sp)
    8000478a:	efde                	sd	s7,472(sp)
    8000478c:	ebe2                	sd	s8,464(sp)
    8000478e:	e7e6                	sd	s9,456(sp)
    80004790:	e3ea                	sd	s10,448(sp)
    80004792:	ff6e                	sd	s11,440(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004794:	e8845783          	lhu	a5,-376(s0)
    80004798:	0e078963          	beqz	a5,8000488a <kexec+0x1a2>
    8000479c:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047a0:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800047a2:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047a4:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    800047a8:	6c85                	lui	s9,0x1
    800047aa:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047ae:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800047b2:	6a85                	lui	s5,0x1
    800047b4:	a085                	j	80004814 <kexec+0x12c>
      panic("loadseg: address should exist");
    800047b6:	00003517          	auipc	a0,0x3
    800047ba:	dea50513          	addi	a0,a0,-534 # 800075a0 <etext+0x5a0>
    800047be:	85afc0ef          	jal	80000818 <panic>
    if (sz - i < PGSIZE)
    800047c2:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800047c4:	874a                	mv	a4,s2
    800047c6:	009b86bb          	addw	a3,s7,s1
    800047ca:	4581                	li	a1,0
    800047cc:	8552                	mv	a0,s4
    800047ce:	dd3fe0ef          	jal	800035a0 <readi>
    800047d2:	22a91b63          	bne	s2,a0,80004a08 <kexec+0x320>
  for (i = 0; i < sz; i += PGSIZE) {
    800047d6:	009a84bb          	addw	s1,s5,s1
    800047da:	0334f263          	bgeu	s1,s3,800047fe <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800047de:	02049593          	slli	a1,s1,0x20
    800047e2:	9181                	srli	a1,a1,0x20
    800047e4:	95e2                	add	a1,a1,s8
    800047e6:	855a                	mv	a0,s6
    800047e8:	813fc0ef          	jal	80000ffa <walkaddr>
    800047ec:	862a                	mv	a2,a0
    if (pa == 0)
    800047ee:	d561                	beqz	a0,800047b6 <kexec+0xce>
    if (sz - i < PGSIZE)
    800047f0:	409987bb          	subw	a5,s3,s1
    800047f4:	893e                	mv	s2,a5
    800047f6:	fcfcf6e3          	bgeu	s9,a5,800047c2 <kexec+0xda>
    800047fa:	8956                	mv	s2,s5
    800047fc:	b7d9                	j	800047c2 <kexec+0xda>
    sz = sz1;
    800047fe:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004802:	2d05                	addiw	s10,s10,1
    80004804:	e0843783          	ld	a5,-504(s0)
    80004808:	0387869b          	addiw	a3,a5,56
    8000480c:	e8845783          	lhu	a5,-376(s0)
    80004810:	06fd5e63          	bge	s10,a5,8000488c <kexec+0x1a4>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004814:	e0d43423          	sd	a3,-504(s0)
    80004818:	876e                	mv	a4,s11
    8000481a:	e1840613          	addi	a2,s0,-488
    8000481e:	4581                	li	a1,0
    80004820:	8552                	mv	a0,s4
    80004822:	d7ffe0ef          	jal	800035a0 <readi>
    80004826:	1db51f63          	bne	a0,s11,80004a04 <kexec+0x31c>
    if (ph.type != ELF_PROG_LOAD)
    8000482a:	e1842783          	lw	a5,-488(s0)
    8000482e:	4705                	li	a4,1
    80004830:	fce799e3          	bne	a5,a4,80004802 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004834:	e4043483          	ld	s1,-448(s0)
    80004838:	e3843783          	ld	a5,-456(s0)
    8000483c:	1ef4e463          	bltu	s1,a5,80004a24 <kexec+0x33c>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004840:	e2843783          	ld	a5,-472(s0)
    80004844:	94be                	add	s1,s1,a5
    80004846:	1ef4e263          	bltu	s1,a5,80004a2a <kexec+0x342>
    if (ph.vaddr % PGSIZE != 0)
    8000484a:	de843703          	ld	a4,-536(s0)
    8000484e:	8ff9                	and	a5,a5,a4
    80004850:	1e079063          	bnez	a5,80004a30 <kexec+0x348>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004854:	e1c42503          	lw	a0,-484(s0)
    80004858:	e71ff0ef          	jal	800046c8 <flags2perm>
    8000485c:	86aa                	mv	a3,a0
    8000485e:	8626                	mv	a2,s1
    80004860:	85ca                	mv	a1,s2
    80004862:	855a                	mv	a0,s6
    80004864:	a6dfc0ef          	jal	800012d0 <uvmalloc>
    80004868:	dea43c23          	sd	a0,-520(s0)
    8000486c:	1c050563          	beqz	a0,80004a36 <kexec+0x34e>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004870:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004874:	00098863          	beqz	s3,80004884 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004878:	e2843c03          	ld	s8,-472(s0)
    8000487c:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004880:	4481                	li	s1,0
    80004882:	bfb1                	j	800047de <kexec+0xf6>
    sz = sz1;
    80004884:	df843903          	ld	s2,-520(s0)
    80004888:	bfad                	j	80004802 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000488a:	4901                	li	s2,0
  iunlockput(ip);
    8000488c:	8552                	mv	a0,s4
    8000488e:	b8dfe0ef          	jal	8000341a <iunlockput>
  end_op();
    80004892:	bf8ff0ef          	jal	80003c8a <end_op>
  p = myproc();
    80004896:	86cfd0ef          	jal	80001902 <myproc>
    8000489a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000489c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800048a0:	6985                	lui	s3,0x1
    800048a2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800048a4:	99ca                	add	s3,s3,s2
    800048a6:	77fd                	lui	a5,0xfffff
    800048a8:	00f9f9b3          	and	s3,s3,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    800048ac:	4691                	li	a3,4
    800048ae:	6609                	lui	a2,0x2
    800048b0:	964e                	add	a2,a2,s3
    800048b2:	85ce                	mv	a1,s3
    800048b4:	855a                	mv	a0,s6
    800048b6:	a1bfc0ef          	jal	800012d0 <uvmalloc>
    800048ba:	8a2a                	mv	s4,a0
    800048bc:	e105                	bnez	a0,800048dc <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800048be:	85ce                	mv	a1,s3
    800048c0:	855a                	mv	a0,s6
    800048c2:	9cefd0ef          	jal	80001a90 <proc_freepagetable>
  return -1;
    800048c6:	557d                	li	a0,-1
    800048c8:	79fe                	ld	s3,504(sp)
    800048ca:	7a5e                	ld	s4,496(sp)
    800048cc:	7abe                	ld	s5,488(sp)
    800048ce:	7b1e                	ld	s6,480(sp)
    800048d0:	6bfe                	ld	s7,472(sp)
    800048d2:	6c5e                	ld	s8,464(sp)
    800048d4:	6cbe                	ld	s9,456(sp)
    800048d6:	6d1e                	ld	s10,448(sp)
    800048d8:	7dfa                	ld	s11,440(sp)
    800048da:	b541                	j	8000475a <kexec+0x72>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    800048dc:	75f9                	lui	a1,0xffffe
    800048de:	95aa                	add	a1,a1,a0
    800048e0:	855a                	mv	a0,s6
    800048e2:	bc1fc0ef          	jal	800014a2 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    800048e6:	800a0b93          	addi	s7,s4,-2048
    800048ea:	800b8b93          	addi	s7,s7,-2048
  for (argc = 0; argv[argc]; argc++) {
    800048ee:	e0043783          	ld	a5,-512(s0)
    800048f2:	6388                	ld	a0,0(a5)
  sp = sz;
    800048f4:	8952                	mv	s2,s4
  for (argc = 0; argv[argc]; argc++) {
    800048f6:	4481                	li	s1,0
    ustack[argc] = sp;
    800048f8:	e9040c93          	addi	s9,s0,-368
    if (argc >= MAXARG)
    800048fc:	02000c13          	li	s8,32
  for (argc = 0; argv[argc]; argc++) {
    80004900:	cd21                	beqz	a0,80004958 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004902:	d54fc0ef          	jal	80000e56 <strlen>
    80004906:	0015079b          	addiw	a5,a0,1
    8000490a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000490e:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    80004912:	13796563          	bltu	s2,s7,80004a3c <kexec+0x354>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004916:	e0043d83          	ld	s11,-512(s0)
    8000491a:	000db983          	ld	s3,0(s11)
    8000491e:	854e                	mv	a0,s3
    80004920:	d36fc0ef          	jal	80000e56 <strlen>
    80004924:	0015069b          	addiw	a3,a0,1
    80004928:	864e                	mv	a2,s3
    8000492a:	85ca                	mv	a1,s2
    8000492c:	855a                	mv	a0,s6
    8000492e:	cfbfc0ef          	jal	80001628 <copyout>
    80004932:	10054763          	bltz	a0,80004a40 <kexec+0x358>
    ustack[argc] = sp;
    80004936:	00349793          	slli	a5,s1,0x3
    8000493a:	97e6                	add	a5,a5,s9
    8000493c:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdba48>
  for (argc = 0; argv[argc]; argc++) {
    80004940:	0485                	addi	s1,s1,1
    80004942:	008d8793          	addi	a5,s11,8
    80004946:	e0f43023          	sd	a5,-512(s0)
    8000494a:	008db503          	ld	a0,8(s11)
    8000494e:	c509                	beqz	a0,80004958 <kexec+0x270>
    if (argc >= MAXARG)
    80004950:	fb8499e3          	bne	s1,s8,80004902 <kexec+0x21a>
  sz = sz1;
    80004954:	89d2                	mv	s3,s4
    80004956:	b7a5                	j	800048be <kexec+0x1d6>
  ustack[argc] = 0;
    80004958:	00349793          	slli	a5,s1,0x3
    8000495c:	f9078793          	addi	a5,a5,-112
    80004960:	97a2                	add	a5,a5,s0
    80004962:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004966:	00349693          	slli	a3,s1,0x3
    8000496a:	06a1                	addi	a3,a3,8
    8000496c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004970:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004974:	89d2                	mv	s3,s4
  if (sp < stackbase)
    80004976:	f57964e3          	bltu	s2,s7,800048be <kexec+0x1d6>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    8000497a:	e9040613          	addi	a2,s0,-368
    8000497e:	85ca                	mv	a1,s2
    80004980:	855a                	mv	a0,s6
    80004982:	ca7fc0ef          	jal	80001628 <copyout>
    80004986:	f2054ce3          	bltz	a0,800048be <kexec+0x1d6>
  p->trapframe->a1 = sp;
    8000498a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000498e:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80004992:	df043783          	ld	a5,-528(s0)
    80004996:	0007c703          	lbu	a4,0(a5)
    8000499a:	cf11                	beqz	a4,800049b6 <kexec+0x2ce>
    8000499c:	0785                	addi	a5,a5,1
    if (*s == '/')
    8000499e:	02f00693          	li	a3,47
    800049a2:	a029                	j	800049ac <kexec+0x2c4>
  for (last = s = path; *s; s++)
    800049a4:	0785                	addi	a5,a5,1
    800049a6:	fff7c703          	lbu	a4,-1(a5)
    800049aa:	c711                	beqz	a4,800049b6 <kexec+0x2ce>
    if (*s == '/')
    800049ac:	fed71ce3          	bne	a4,a3,800049a4 <kexec+0x2bc>
      last = s + 1;
    800049b0:	def43823          	sd	a5,-528(s0)
    800049b4:	bfc5                	j	800049a4 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    800049b6:	4641                	li	a2,16
    800049b8:	df043583          	ld	a1,-528(s0)
    800049bc:	158a8513          	addi	a0,s5,344
    800049c0:	c60fc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    800049c4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800049c8:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800049cc:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    800049d0:	058ab783          	ld	a5,88(s5)
    800049d4:	e6843703          	ld	a4,-408(s0)
    800049d8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    800049da:	058ab783          	ld	a5,88(s5)
    800049de:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800049e2:	85ea                	mv	a1,s10
    800049e4:	8acfd0ef          	jal	80001a90 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800049e8:	0004851b          	sext.w	a0,s1
    800049ec:	79fe                	ld	s3,504(sp)
    800049ee:	7a5e                	ld	s4,496(sp)
    800049f0:	7abe                	ld	s5,488(sp)
    800049f2:	7b1e                	ld	s6,480(sp)
    800049f4:	6bfe                	ld	s7,472(sp)
    800049f6:	6c5e                	ld	s8,464(sp)
    800049f8:	6cbe                	ld	s9,456(sp)
    800049fa:	6d1e                	ld	s10,448(sp)
    800049fc:	7dfa                	ld	s11,440(sp)
    800049fe:	bbb1                	j	8000475a <kexec+0x72>
    80004a00:	7b1e                	ld	s6,480(sp)
    80004a02:	b3a9                	j	8000474c <kexec+0x64>
    80004a04:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004a08:	df843583          	ld	a1,-520(s0)
    80004a0c:	855a                	mv	a0,s6
    80004a0e:	882fd0ef          	jal	80001a90 <proc_freepagetable>
  if (ip) {
    80004a12:	79fe                	ld	s3,504(sp)
    80004a14:	7abe                	ld	s5,488(sp)
    80004a16:	7b1e                	ld	s6,480(sp)
    80004a18:	6bfe                	ld	s7,472(sp)
    80004a1a:	6c5e                	ld	s8,464(sp)
    80004a1c:	6cbe                	ld	s9,456(sp)
    80004a1e:	6d1e                	ld	s10,448(sp)
    80004a20:	7dfa                	ld	s11,440(sp)
    80004a22:	b32d                	j	8000474c <kexec+0x64>
    80004a24:	df243c23          	sd	s2,-520(s0)
    80004a28:	b7c5                	j	80004a08 <kexec+0x320>
    80004a2a:	df243c23          	sd	s2,-520(s0)
    80004a2e:	bfe9                	j	80004a08 <kexec+0x320>
    80004a30:	df243c23          	sd	s2,-520(s0)
    80004a34:	bfd1                	j	80004a08 <kexec+0x320>
    80004a36:	df243c23          	sd	s2,-520(s0)
    80004a3a:	b7f9                	j	80004a08 <kexec+0x320>
  sz = sz1;
    80004a3c:	89d2                	mv	s3,s4
    80004a3e:	b541                	j	800048be <kexec+0x1d6>
    80004a40:	89d2                	mv	s3,s4
    80004a42:	bdb5                	j	800048be <kexec+0x1d6>

0000000080004a44 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a44:	7179                	addi	sp,sp,-48
    80004a46:	f406                	sd	ra,40(sp)
    80004a48:	f022                	sd	s0,32(sp)
    80004a4a:	ec26                	sd	s1,24(sp)
    80004a4c:	e84a                	sd	s2,16(sp)
    80004a4e:	1800                	addi	s0,sp,48
    80004a50:	892e                	mv	s2,a1
    80004a52:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a54:	fdc40593          	addi	a1,s0,-36
    80004a58:	dbdfd0ef          	jal	80002814 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004a5c:	fdc42703          	lw	a4,-36(s0)
    80004a60:	47bd                	li	a5,15
    80004a62:	02e7ea63          	bltu	a5,a4,80004a96 <argfd+0x52>
    80004a66:	e9dfc0ef          	jal	80001902 <myproc>
    80004a6a:	fdc42703          	lw	a4,-36(s0)
    80004a6e:	00371793          	slli	a5,a4,0x3
    80004a72:	0d078793          	addi	a5,a5,208
    80004a76:	953e                	add	a0,a0,a5
    80004a78:	611c                	ld	a5,0(a0)
    80004a7a:	c385                	beqz	a5,80004a9a <argfd+0x56>
    return -1;
  if (pfd)
    80004a7c:	00090463          	beqz	s2,80004a84 <argfd+0x40>
    *pfd = fd;
    80004a80:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004a84:	4501                	li	a0,0
  if (pf)
    80004a86:	c091                	beqz	s1,80004a8a <argfd+0x46>
    *pf = f;
    80004a88:	e09c                	sd	a5,0(s1)
}
    80004a8a:	70a2                	ld	ra,40(sp)
    80004a8c:	7402                	ld	s0,32(sp)
    80004a8e:	64e2                	ld	s1,24(sp)
    80004a90:	6942                	ld	s2,16(sp)
    80004a92:	6145                	addi	sp,sp,48
    80004a94:	8082                	ret
    return -1;
    80004a96:	557d                	li	a0,-1
    80004a98:	bfcd                	j	80004a8a <argfd+0x46>
    80004a9a:	557d                	li	a0,-1
    80004a9c:	b7fd                	j	80004a8a <argfd+0x46>

0000000080004a9e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a9e:	1101                	addi	sp,sp,-32
    80004aa0:	ec06                	sd	ra,24(sp)
    80004aa2:	e822                	sd	s0,16(sp)
    80004aa4:	e426                	sd	s1,8(sp)
    80004aa6:	1000                	addi	s0,sp,32
    80004aa8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004aaa:	e59fc0ef          	jal	80001902 <myproc>
    80004aae:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004ab0:	0d050793          	addi	a5,a0,208
    80004ab4:	4501                	li	a0,0
    80004ab6:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004ab8:	6398                	ld	a4,0(a5)
    80004aba:	cb19                	beqz	a4,80004ad0 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004abc:	2505                	addiw	a0,a0,1
    80004abe:	07a1                	addi	a5,a5,8
    80004ac0:	fed51ce3          	bne	a0,a3,80004ab8 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ac4:	557d                	li	a0,-1
}
    80004ac6:	60e2                	ld	ra,24(sp)
    80004ac8:	6442                	ld	s0,16(sp)
    80004aca:	64a2                	ld	s1,8(sp)
    80004acc:	6105                	addi	sp,sp,32
    80004ace:	8082                	ret
      p->ofile[fd] = f;
    80004ad0:	00351793          	slli	a5,a0,0x3
    80004ad4:	0d078793          	addi	a5,a5,208
    80004ad8:	963e                	add	a2,a2,a5
    80004ada:	e204                	sd	s1,0(a2)
      return fd;
    80004adc:	b7ed                	j	80004ac6 <fdalloc+0x28>

0000000080004ade <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004ade:	715d                	addi	sp,sp,-80
    80004ae0:	e486                	sd	ra,72(sp)
    80004ae2:	e0a2                	sd	s0,64(sp)
    80004ae4:	fc26                	sd	s1,56(sp)
    80004ae6:	f84a                	sd	s2,48(sp)
    80004ae8:	f44e                	sd	s3,40(sp)
    80004aea:	f052                	sd	s4,32(sp)
    80004aec:	ec56                	sd	s5,24(sp)
    80004aee:	e85a                	sd	s6,16(sp)
    80004af0:	0880                	addi	s0,sp,80
    80004af2:	892e                	mv	s2,a1
    80004af4:	8a2e                	mv	s4,a1
    80004af6:	8ab2                	mv	s5,a2
    80004af8:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004afa:	fb040593          	addi	a1,s0,-80
    80004afe:	f59fe0ef          	jal	80003a56 <nameiparent>
    80004b02:	84aa                	mv	s1,a0
    80004b04:	10050763          	beqz	a0,80004c12 <create+0x134>
    return 0;

  ilock(dp);
    80004b08:	f06fe0ef          	jal	8000320e <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004b0c:	4601                	li	a2,0
    80004b0e:	fb040593          	addi	a1,s0,-80
    80004b12:	8526                	mv	a0,s1
    80004b14:	c95fe0ef          	jal	800037a8 <dirlookup>
    80004b18:	89aa                	mv	s3,a0
    80004b1a:	c131                	beqz	a0,80004b5e <create+0x80>
    iunlockput(dp);
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	8fdfe0ef          	jal	8000341a <iunlockput>
    ilock(ip);
    80004b22:	854e                	mv	a0,s3
    80004b24:	eeafe0ef          	jal	8000320e <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b28:	4789                	li	a5,2
    80004b2a:	02f91563          	bne	s2,a5,80004b54 <create+0x76>
    80004b2e:	0449d783          	lhu	a5,68(s3)
    80004b32:	37f9                	addiw	a5,a5,-2
    80004b34:	17c2                	slli	a5,a5,0x30
    80004b36:	93c1                	srli	a5,a5,0x30
    80004b38:	4705                	li	a4,1
    80004b3a:	00f76d63          	bltu	a4,a5,80004b54 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b3e:	854e                	mv	a0,s3
    80004b40:	60a6                	ld	ra,72(sp)
    80004b42:	6406                	ld	s0,64(sp)
    80004b44:	74e2                	ld	s1,56(sp)
    80004b46:	7942                	ld	s2,48(sp)
    80004b48:	79a2                	ld	s3,40(sp)
    80004b4a:	7a02                	ld	s4,32(sp)
    80004b4c:	6ae2                	ld	s5,24(sp)
    80004b4e:	6b42                	ld	s6,16(sp)
    80004b50:	6161                	addi	sp,sp,80
    80004b52:	8082                	ret
    iunlockput(ip);
    80004b54:	854e                	mv	a0,s3
    80004b56:	8c5fe0ef          	jal	8000341a <iunlockput>
    return 0;
    80004b5a:	4981                	li	s3,0
    80004b5c:	b7cd                	j	80004b3e <create+0x60>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004b5e:	85ca                	mv	a1,s2
    80004b60:	4088                	lw	a0,0(s1)
    80004b62:	d3cfe0ef          	jal	8000309e <ialloc>
    80004b66:	892a                	mv	s2,a0
    80004b68:	cd15                	beqz	a0,80004ba4 <create+0xc6>
  ilock(ip);
    80004b6a:	ea4fe0ef          	jal	8000320e <ilock>
  ip->major = major;
    80004b6e:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004b72:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004b76:	4785                	li	a5,1
    80004b78:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004b7c:	854a                	mv	a0,s2
    80004b7e:	ddcfe0ef          	jal	8000315a <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004b82:	4705                	li	a4,1
    80004b84:	02ea0463          	beq	s4,a4,80004bac <create+0xce>
  if (dirlink(dp, name, ip->inum) < 0)
    80004b88:	00492603          	lw	a2,4(s2)
    80004b8c:	fb040593          	addi	a1,s0,-80
    80004b90:	8526                	mv	a0,s1
    80004b92:	e01fe0ef          	jal	80003992 <dirlink>
    80004b96:	06054263          	bltz	a0,80004bfa <create+0x11c>
  iunlockput(dp);
    80004b9a:	8526                	mv	a0,s1
    80004b9c:	87ffe0ef          	jal	8000341a <iunlockput>
  return ip;
    80004ba0:	89ca                	mv	s3,s2
    80004ba2:	bf71                	j	80004b3e <create+0x60>
    iunlockput(dp);
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	875fe0ef          	jal	8000341a <iunlockput>
    return 0;
    80004baa:	bf51                	j	80004b3e <create+0x60>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004bac:	00492603          	lw	a2,4(s2)
    80004bb0:	00003597          	auipc	a1,0x3
    80004bb4:	a1058593          	addi	a1,a1,-1520 # 800075c0 <etext+0x5c0>
    80004bb8:	854a                	mv	a0,s2
    80004bba:	dd9fe0ef          	jal	80003992 <dirlink>
    80004bbe:	02054e63          	bltz	a0,80004bfa <create+0x11c>
    80004bc2:	40d0                	lw	a2,4(s1)
    80004bc4:	00003597          	auipc	a1,0x3
    80004bc8:	a0458593          	addi	a1,a1,-1532 # 800075c8 <etext+0x5c8>
    80004bcc:	854a                	mv	a0,s2
    80004bce:	dc5fe0ef          	jal	80003992 <dirlink>
    80004bd2:	02054463          	bltz	a0,80004bfa <create+0x11c>
  if (dirlink(dp, name, ip->inum) < 0)
    80004bd6:	00492603          	lw	a2,4(s2)
    80004bda:	fb040593          	addi	a1,s0,-80
    80004bde:	8526                	mv	a0,s1
    80004be0:	db3fe0ef          	jal	80003992 <dirlink>
    80004be4:	00054b63          	bltz	a0,80004bfa <create+0x11c>
    dp->nlink++; // for ".."
    80004be8:	04a4d783          	lhu	a5,74(s1)
    80004bec:	2785                	addiw	a5,a5,1
    80004bee:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004bf2:	8526                	mv	a0,s1
    80004bf4:	d66fe0ef          	jal	8000315a <iupdate>
    80004bf8:	b74d                	j	80004b9a <create+0xbc>
  ip->nlink = 0;
    80004bfa:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004bfe:	854a                	mv	a0,s2
    80004c00:	d5afe0ef          	jal	8000315a <iupdate>
  iunlockput(ip);
    80004c04:	854a                	mv	a0,s2
    80004c06:	815fe0ef          	jal	8000341a <iunlockput>
  iunlockput(dp);
    80004c0a:	8526                	mv	a0,s1
    80004c0c:	80ffe0ef          	jal	8000341a <iunlockput>
  return 0;
    80004c10:	b73d                	j	80004b3e <create+0x60>
    return 0;
    80004c12:	89aa                	mv	s3,a0
    80004c14:	b72d                	j	80004b3e <create+0x60>

0000000080004c16 <sys_dup>:
{
    80004c16:	7179                	addi	sp,sp,-48
    80004c18:	f406                	sd	ra,40(sp)
    80004c1a:	f022                	sd	s0,32(sp)
    80004c1c:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004c1e:	fd840613          	addi	a2,s0,-40
    80004c22:	4581                	li	a1,0
    80004c24:	4501                	li	a0,0
    80004c26:	e1fff0ef          	jal	80004a44 <argfd>
    return -1;
    80004c2a:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004c2c:	02054363          	bltz	a0,80004c52 <sys_dup+0x3c>
    80004c30:	ec26                	sd	s1,24(sp)
    80004c32:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004c34:	fd843483          	ld	s1,-40(s0)
    80004c38:	8526                	mv	a0,s1
    80004c3a:	e65ff0ef          	jal	80004a9e <fdalloc>
    80004c3e:	892a                	mv	s2,a0
    return -1;
    80004c40:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004c42:	00054d63          	bltz	a0,80004c5c <sys_dup+0x46>
  filedup(f);
    80004c46:	8526                	mv	a0,s1
    80004c48:	c0eff0ef          	jal	80004056 <filedup>
  return fd;
    80004c4c:	87ca                	mv	a5,s2
    80004c4e:	64e2                	ld	s1,24(sp)
    80004c50:	6942                	ld	s2,16(sp)
}
    80004c52:	853e                	mv	a0,a5
    80004c54:	70a2                	ld	ra,40(sp)
    80004c56:	7402                	ld	s0,32(sp)
    80004c58:	6145                	addi	sp,sp,48
    80004c5a:	8082                	ret
    80004c5c:	64e2                	ld	s1,24(sp)
    80004c5e:	6942                	ld	s2,16(sp)
    80004c60:	bfcd                	j	80004c52 <sys_dup+0x3c>

0000000080004c62 <sys_read>:
{
    80004c62:	7179                	addi	sp,sp,-48
    80004c64:	f406                	sd	ra,40(sp)
    80004c66:	f022                	sd	s0,32(sp)
    80004c68:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c6a:	fd840593          	addi	a1,s0,-40
    80004c6e:	4505                	li	a0,1
    80004c70:	bc1fd0ef          	jal	80002830 <argaddr>
  argint(2, &n);
    80004c74:	fe440593          	addi	a1,s0,-28
    80004c78:	4509                	li	a0,2
    80004c7a:	b9bfd0ef          	jal	80002814 <argint>
  if (argfd(0, 0, &f) < 0)
    80004c7e:	fe840613          	addi	a2,s0,-24
    80004c82:	4581                	li	a1,0
    80004c84:	4501                	li	a0,0
    80004c86:	dbfff0ef          	jal	80004a44 <argfd>
    80004c8a:	87aa                	mv	a5,a0
    return -1;
    80004c8c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004c8e:	0007ca63          	bltz	a5,80004ca2 <sys_read+0x40>
  return fileread(f, p, n);
    80004c92:	fe442603          	lw	a2,-28(s0)
    80004c96:	fd843583          	ld	a1,-40(s0)
    80004c9a:	fe843503          	ld	a0,-24(s0)
    80004c9e:	d22ff0ef          	jal	800041c0 <fileread>
}
    80004ca2:	70a2                	ld	ra,40(sp)
    80004ca4:	7402                	ld	s0,32(sp)
    80004ca6:	6145                	addi	sp,sp,48
    80004ca8:	8082                	ret

0000000080004caa <sys_write>:
{
    80004caa:	7179                	addi	sp,sp,-48
    80004cac:	f406                	sd	ra,40(sp)
    80004cae:	f022                	sd	s0,32(sp)
    80004cb0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cb2:	fd840593          	addi	a1,s0,-40
    80004cb6:	4505                	li	a0,1
    80004cb8:	b79fd0ef          	jal	80002830 <argaddr>
  argint(2, &n);
    80004cbc:	fe440593          	addi	a1,s0,-28
    80004cc0:	4509                	li	a0,2
    80004cc2:	b53fd0ef          	jal	80002814 <argint>
  if (argfd(0, 0, &f) < 0)
    80004cc6:	fe840613          	addi	a2,s0,-24
    80004cca:	4581                	li	a1,0
    80004ccc:	4501                	li	a0,0
    80004cce:	d77ff0ef          	jal	80004a44 <argfd>
    80004cd2:	87aa                	mv	a5,a0
    return -1;
    80004cd4:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004cd6:	0007ca63          	bltz	a5,80004cea <sys_write+0x40>
  return filewrite(f, p, n);
    80004cda:	fe442603          	lw	a2,-28(s0)
    80004cde:	fd843583          	ld	a1,-40(s0)
    80004ce2:	fe843503          	ld	a0,-24(s0)
    80004ce6:	d9eff0ef          	jal	80004284 <filewrite>
}
    80004cea:	70a2                	ld	ra,40(sp)
    80004cec:	7402                	ld	s0,32(sp)
    80004cee:	6145                	addi	sp,sp,48
    80004cf0:	8082                	ret

0000000080004cf2 <sys_close>:
{
    80004cf2:	1101                	addi	sp,sp,-32
    80004cf4:	ec06                	sd	ra,24(sp)
    80004cf6:	e822                	sd	s0,16(sp)
    80004cf8:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004cfa:	fe040613          	addi	a2,s0,-32
    80004cfe:	fec40593          	addi	a1,s0,-20
    80004d02:	4501                	li	a0,0
    80004d04:	d41ff0ef          	jal	80004a44 <argfd>
    return -1;
    80004d08:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004d0a:	02054163          	bltz	a0,80004d2c <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004d0e:	bf5fc0ef          	jal	80001902 <myproc>
    80004d12:	fec42783          	lw	a5,-20(s0)
    80004d16:	078e                	slli	a5,a5,0x3
    80004d18:	0d078793          	addi	a5,a5,208
    80004d1c:	953e                	add	a0,a0,a5
    80004d1e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d22:	fe043503          	ld	a0,-32(s0)
    80004d26:	b76ff0ef          	jal	8000409c <fileclose>
  return 0;
    80004d2a:	4781                	li	a5,0
}
    80004d2c:	853e                	mv	a0,a5
    80004d2e:	60e2                	ld	ra,24(sp)
    80004d30:	6442                	ld	s0,16(sp)
    80004d32:	6105                	addi	sp,sp,32
    80004d34:	8082                	ret

0000000080004d36 <sys_fstat>:
{
    80004d36:	1101                	addi	sp,sp,-32
    80004d38:	ec06                	sd	ra,24(sp)
    80004d3a:	e822                	sd	s0,16(sp)
    80004d3c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d3e:	fe040593          	addi	a1,s0,-32
    80004d42:	4505                	li	a0,1
    80004d44:	aedfd0ef          	jal	80002830 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004d48:	fe840613          	addi	a2,s0,-24
    80004d4c:	4581                	li	a1,0
    80004d4e:	4501                	li	a0,0
    80004d50:	cf5ff0ef          	jal	80004a44 <argfd>
    80004d54:	87aa                	mv	a5,a0
    return -1;
    80004d56:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004d58:	0007c863          	bltz	a5,80004d68 <sys_fstat+0x32>
  return filestat(f, st);
    80004d5c:	fe043583          	ld	a1,-32(s0)
    80004d60:	fe843503          	ld	a0,-24(s0)
    80004d64:	bfaff0ef          	jal	8000415e <filestat>
}
    80004d68:	60e2                	ld	ra,24(sp)
    80004d6a:	6442                	ld	s0,16(sp)
    80004d6c:	6105                	addi	sp,sp,32
    80004d6e:	8082                	ret

0000000080004d70 <sys_link>:
{
    80004d70:	7169                	addi	sp,sp,-304
    80004d72:	f606                	sd	ra,296(sp)
    80004d74:	f222                	sd	s0,288(sp)
    80004d76:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d78:	08000613          	li	a2,128
    80004d7c:	ed040593          	addi	a1,s0,-304
    80004d80:	4501                	li	a0,0
    80004d82:	acbfd0ef          	jal	8000284c <argstr>
    return -1;
    80004d86:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d88:	0c054e63          	bltz	a0,80004e64 <sys_link+0xf4>
    80004d8c:	08000613          	li	a2,128
    80004d90:	f5040593          	addi	a1,s0,-176
    80004d94:	4505                	li	a0,1
    80004d96:	ab7fd0ef          	jal	8000284c <argstr>
    return -1;
    80004d9a:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d9c:	0c054463          	bltz	a0,80004e64 <sys_link+0xf4>
    80004da0:	ee26                	sd	s1,280(sp)
  begin_op();
    80004da2:	e79fe0ef          	jal	80003c1a <begin_op>
  if ((ip = namei(old)) == 0) {
    80004da6:	ed040513          	addi	a0,s0,-304
    80004daa:	c93fe0ef          	jal	80003a3c <namei>
    80004dae:	84aa                	mv	s1,a0
    80004db0:	c53d                	beqz	a0,80004e1e <sys_link+0xae>
  ilock(ip);
    80004db2:	c5cfe0ef          	jal	8000320e <ilock>
  if (ip->type == T_DIR) {
    80004db6:	04449703          	lh	a4,68(s1)
    80004dba:	4785                	li	a5,1
    80004dbc:	06f70663          	beq	a4,a5,80004e28 <sys_link+0xb8>
    80004dc0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004dc2:	04a4d783          	lhu	a5,74(s1)
    80004dc6:	2785                	addiw	a5,a5,1
    80004dc8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dcc:	8526                	mv	a0,s1
    80004dce:	b8cfe0ef          	jal	8000315a <iupdate>
  iunlock(ip);
    80004dd2:	8526                	mv	a0,s1
    80004dd4:	ce8fe0ef          	jal	800032bc <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004dd8:	fd040593          	addi	a1,s0,-48
    80004ddc:	f5040513          	addi	a0,s0,-176
    80004de0:	c77fe0ef          	jal	80003a56 <nameiparent>
    80004de4:	892a                	mv	s2,a0
    80004de6:	cd21                	beqz	a0,80004e3e <sys_link+0xce>
  ilock(dp);
    80004de8:	c26fe0ef          	jal	8000320e <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004dec:	854a                	mv	a0,s2
    80004dee:	00092703          	lw	a4,0(s2)
    80004df2:	409c                	lw	a5,0(s1)
    80004df4:	04f71263          	bne	a4,a5,80004e38 <sys_link+0xc8>
    80004df8:	40d0                	lw	a2,4(s1)
    80004dfa:	fd040593          	addi	a1,s0,-48
    80004dfe:	b95fe0ef          	jal	80003992 <dirlink>
    80004e02:	02054b63          	bltz	a0,80004e38 <sys_link+0xc8>
  iunlockput(dp);
    80004e06:	854a                	mv	a0,s2
    80004e08:	e12fe0ef          	jal	8000341a <iunlockput>
  iput(ip);
    80004e0c:	8526                	mv	a0,s1
    80004e0e:	d82fe0ef          	jal	80003390 <iput>
  end_op();
    80004e12:	e79fe0ef          	jal	80003c8a <end_op>
  return 0;
    80004e16:	4781                	li	a5,0
    80004e18:	64f2                	ld	s1,280(sp)
    80004e1a:	6952                	ld	s2,272(sp)
    80004e1c:	a0a1                	j	80004e64 <sys_link+0xf4>
    end_op();
    80004e1e:	e6dfe0ef          	jal	80003c8a <end_op>
    return -1;
    80004e22:	57fd                	li	a5,-1
    80004e24:	64f2                	ld	s1,280(sp)
    80004e26:	a83d                	j	80004e64 <sys_link+0xf4>
    iunlockput(ip);
    80004e28:	8526                	mv	a0,s1
    80004e2a:	df0fe0ef          	jal	8000341a <iunlockput>
    end_op();
    80004e2e:	e5dfe0ef          	jal	80003c8a <end_op>
    return -1;
    80004e32:	57fd                	li	a5,-1
    80004e34:	64f2                	ld	s1,280(sp)
    80004e36:	a03d                	j	80004e64 <sys_link+0xf4>
    iunlockput(dp);
    80004e38:	854a                	mv	a0,s2
    80004e3a:	de0fe0ef          	jal	8000341a <iunlockput>
  ilock(ip);
    80004e3e:	8526                	mv	a0,s1
    80004e40:	bcefe0ef          	jal	8000320e <ilock>
  ip->nlink--;
    80004e44:	04a4d783          	lhu	a5,74(s1)
    80004e48:	37fd                	addiw	a5,a5,-1
    80004e4a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	b0afe0ef          	jal	8000315a <iupdate>
  iunlockput(ip);
    80004e54:	8526                	mv	a0,s1
    80004e56:	dc4fe0ef          	jal	8000341a <iunlockput>
  end_op();
    80004e5a:	e31fe0ef          	jal	80003c8a <end_op>
  return -1;
    80004e5e:	57fd                	li	a5,-1
    80004e60:	64f2                	ld	s1,280(sp)
    80004e62:	6952                	ld	s2,272(sp)
}
    80004e64:	853e                	mv	a0,a5
    80004e66:	70b2                	ld	ra,296(sp)
    80004e68:	7412                	ld	s0,288(sp)
    80004e6a:	6155                	addi	sp,sp,304
    80004e6c:	8082                	ret

0000000080004e6e <sys_unlink>:
{
    80004e6e:	7151                	addi	sp,sp,-240
    80004e70:	f586                	sd	ra,232(sp)
    80004e72:	f1a2                	sd	s0,224(sp)
    80004e74:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80004e76:	08000613          	li	a2,128
    80004e7a:	f3040593          	addi	a1,s0,-208
    80004e7e:	4501                	li	a0,0
    80004e80:	9cdfd0ef          	jal	8000284c <argstr>
    80004e84:	14054d63          	bltz	a0,80004fde <sys_unlink+0x170>
    80004e88:	eda6                	sd	s1,216(sp)
  begin_op();
    80004e8a:	d91fe0ef          	jal	80003c1a <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80004e8e:	fb040593          	addi	a1,s0,-80
    80004e92:	f3040513          	addi	a0,s0,-208
    80004e96:	bc1fe0ef          	jal	80003a56 <nameiparent>
    80004e9a:	84aa                	mv	s1,a0
    80004e9c:	c955                	beqz	a0,80004f50 <sys_unlink+0xe2>
  ilock(dp);
    80004e9e:	b70fe0ef          	jal	8000320e <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ea2:	00002597          	auipc	a1,0x2
    80004ea6:	71e58593          	addi	a1,a1,1822 # 800075c0 <etext+0x5c0>
    80004eaa:	fb040513          	addi	a0,s0,-80
    80004eae:	8e5fe0ef          	jal	80003792 <namecmp>
    80004eb2:	10050b63          	beqz	a0,80004fc8 <sys_unlink+0x15a>
    80004eb6:	00002597          	auipc	a1,0x2
    80004eba:	71258593          	addi	a1,a1,1810 # 800075c8 <etext+0x5c8>
    80004ebe:	fb040513          	addi	a0,s0,-80
    80004ec2:	8d1fe0ef          	jal	80003792 <namecmp>
    80004ec6:	10050163          	beqz	a0,80004fc8 <sys_unlink+0x15a>
    80004eca:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80004ecc:	f2c40613          	addi	a2,s0,-212
    80004ed0:	fb040593          	addi	a1,s0,-80
    80004ed4:	8526                	mv	a0,s1
    80004ed6:	8d3fe0ef          	jal	800037a8 <dirlookup>
    80004eda:	892a                	mv	s2,a0
    80004edc:	0e050563          	beqz	a0,80004fc6 <sys_unlink+0x158>
    80004ee0:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80004ee2:	b2cfe0ef          	jal	8000320e <ilock>
  if (ip->nlink < 1)
    80004ee6:	04a91783          	lh	a5,74(s2)
    80004eea:	06f05863          	blez	a5,80004f5a <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80004eee:	04491703          	lh	a4,68(s2)
    80004ef2:	4785                	li	a5,1
    80004ef4:	06f70963          	beq	a4,a5,80004f66 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80004ef8:	fc040993          	addi	s3,s0,-64
    80004efc:	4641                	li	a2,16
    80004efe:	4581                	li	a1,0
    80004f00:	854e                	mv	a0,s3
    80004f02:	dcbfb0ef          	jal	80000ccc <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f06:	4741                	li	a4,16
    80004f08:	f2c42683          	lw	a3,-212(s0)
    80004f0c:	864e                	mv	a2,s3
    80004f0e:	4581                	li	a1,0
    80004f10:	8526                	mv	a0,s1
    80004f12:	f80fe0ef          	jal	80003692 <writei>
    80004f16:	47c1                	li	a5,16
    80004f18:	08f51863          	bne	a0,a5,80004fa8 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80004f1c:	04491703          	lh	a4,68(s2)
    80004f20:	4785                	li	a5,1
    80004f22:	08f70963          	beq	a4,a5,80004fb4 <sys_unlink+0x146>
  iunlockput(dp);
    80004f26:	8526                	mv	a0,s1
    80004f28:	cf2fe0ef          	jal	8000341a <iunlockput>
  ip->nlink--;
    80004f2c:	04a95783          	lhu	a5,74(s2)
    80004f30:	37fd                	addiw	a5,a5,-1
    80004f32:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f36:	854a                	mv	a0,s2
    80004f38:	a22fe0ef          	jal	8000315a <iupdate>
  iunlockput(ip);
    80004f3c:	854a                	mv	a0,s2
    80004f3e:	cdcfe0ef          	jal	8000341a <iunlockput>
  end_op();
    80004f42:	d49fe0ef          	jal	80003c8a <end_op>
  return 0;
    80004f46:	4501                	li	a0,0
    80004f48:	64ee                	ld	s1,216(sp)
    80004f4a:	694e                	ld	s2,208(sp)
    80004f4c:	69ae                	ld	s3,200(sp)
    80004f4e:	a061                	j	80004fd6 <sys_unlink+0x168>
    end_op();
    80004f50:	d3bfe0ef          	jal	80003c8a <end_op>
    return -1;
    80004f54:	557d                	li	a0,-1
    80004f56:	64ee                	ld	s1,216(sp)
    80004f58:	a8bd                	j	80004fd6 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004f5a:	00002517          	auipc	a0,0x2
    80004f5e:	67650513          	addi	a0,a0,1654 # 800075d0 <etext+0x5d0>
    80004f62:	8b7fb0ef          	jal	80000818 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80004f66:	04c92703          	lw	a4,76(s2)
    80004f6a:	02000793          	li	a5,32
    80004f6e:	f8e7f5e3          	bgeu	a5,a4,80004ef8 <sys_unlink+0x8a>
    80004f72:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f74:	4741                	li	a4,16
    80004f76:	86ce                	mv	a3,s3
    80004f78:	f1840613          	addi	a2,s0,-232
    80004f7c:	4581                	li	a1,0
    80004f7e:	854a                	mv	a0,s2
    80004f80:	e20fe0ef          	jal	800035a0 <readi>
    80004f84:	47c1                	li	a5,16
    80004f86:	00f51b63          	bne	a0,a5,80004f9c <sys_unlink+0x12e>
    if (de.inum != 0)
    80004f8a:	f1845783          	lhu	a5,-232(s0)
    80004f8e:	ebb1                	bnez	a5,80004fe2 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80004f90:	29c1                	addiw	s3,s3,16
    80004f92:	04c92783          	lw	a5,76(s2)
    80004f96:	fcf9efe3          	bltu	s3,a5,80004f74 <sys_unlink+0x106>
    80004f9a:	bfb9                	j	80004ef8 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004f9c:	00002517          	auipc	a0,0x2
    80004fa0:	64c50513          	addi	a0,a0,1612 # 800075e8 <etext+0x5e8>
    80004fa4:	875fb0ef          	jal	80000818 <panic>
    panic("unlink: writei");
    80004fa8:	00002517          	auipc	a0,0x2
    80004fac:	65850513          	addi	a0,a0,1624 # 80007600 <etext+0x600>
    80004fb0:	869fb0ef          	jal	80000818 <panic>
    dp->nlink--;
    80004fb4:	04a4d783          	lhu	a5,74(s1)
    80004fb8:	37fd                	addiw	a5,a5,-1
    80004fba:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fbe:	8526                	mv	a0,s1
    80004fc0:	99afe0ef          	jal	8000315a <iupdate>
    80004fc4:	b78d                	j	80004f26 <sys_unlink+0xb8>
    80004fc6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004fc8:	8526                	mv	a0,s1
    80004fca:	c50fe0ef          	jal	8000341a <iunlockput>
  end_op();
    80004fce:	cbdfe0ef          	jal	80003c8a <end_op>
  return -1;
    80004fd2:	557d                	li	a0,-1
    80004fd4:	64ee                	ld	s1,216(sp)
}
    80004fd6:	70ae                	ld	ra,232(sp)
    80004fd8:	740e                	ld	s0,224(sp)
    80004fda:	616d                	addi	sp,sp,240
    80004fdc:	8082                	ret
    return -1;
    80004fde:	557d                	li	a0,-1
    80004fe0:	bfdd                	j	80004fd6 <sys_unlink+0x168>
    iunlockput(ip);
    80004fe2:	854a                	mv	a0,s2
    80004fe4:	c36fe0ef          	jal	8000341a <iunlockput>
    goto bad;
    80004fe8:	694e                	ld	s2,208(sp)
    80004fea:	69ae                	ld	s3,200(sp)
    80004fec:	bff1                	j	80004fc8 <sys_unlink+0x15a>

0000000080004fee <sys_open>:

uint64
sys_open(void)
{
    80004fee:	7131                	addi	sp,sp,-192
    80004ff0:	fd06                	sd	ra,184(sp)
    80004ff2:	f922                	sd	s0,176(sp)
    80004ff4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004ff6:	f4c40593          	addi	a1,s0,-180
    80004ffa:	4505                	li	a0,1
    80004ffc:	819fd0ef          	jal	80002814 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005000:	08000613          	li	a2,128
    80005004:	f5040593          	addi	a1,s0,-176
    80005008:	4501                	li	a0,0
    8000500a:	843fd0ef          	jal	8000284c <argstr>
    8000500e:	87aa                	mv	a5,a0
    return -1;
    80005010:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005012:	0a07c363          	bltz	a5,800050b8 <sys_open+0xca>
    80005016:	f526                	sd	s1,168(sp)

  begin_op();
    80005018:	c03fe0ef          	jal	80003c1a <begin_op>

  if (omode & O_CREATE) {
    8000501c:	f4c42783          	lw	a5,-180(s0)
    80005020:	2007f793          	andi	a5,a5,512
    80005024:	c3dd                	beqz	a5,800050ca <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005026:	4681                	li	a3,0
    80005028:	4601                	li	a2,0
    8000502a:	4589                	li	a1,2
    8000502c:	f5040513          	addi	a0,s0,-176
    80005030:	aafff0ef          	jal	80004ade <create>
    80005034:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005036:	c549                	beqz	a0,800050c0 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005038:	04449703          	lh	a4,68(s1)
    8000503c:	478d                	li	a5,3
    8000503e:	00f71763          	bne	a4,a5,8000504c <sys_open+0x5e>
    80005042:	0464d703          	lhu	a4,70(s1)
    80005046:	47a5                	li	a5,9
    80005048:	0ae7ee63          	bltu	a5,a4,80005104 <sys_open+0x116>
    8000504c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    8000504e:	fabfe0ef          	jal	80003ff8 <filealloc>
    80005052:	892a                	mv	s2,a0
    80005054:	c561                	beqz	a0,8000511c <sys_open+0x12e>
    80005056:	ed4e                	sd	s3,152(sp)
    80005058:	a47ff0ef          	jal	80004a9e <fdalloc>
    8000505c:	89aa                	mv	s3,a0
    8000505e:	0a054b63          	bltz	a0,80005114 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005062:	04449703          	lh	a4,68(s1)
    80005066:	478d                	li	a5,3
    80005068:	0cf70363          	beq	a4,a5,8000512e <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000506c:	4789                	li	a5,2
    8000506e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005072:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005076:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000507a:	f4c42783          	lw	a5,-180(s0)
    8000507e:	0017f713          	andi	a4,a5,1
    80005082:	00174713          	xori	a4,a4,1
    80005086:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000508a:	0037f713          	andi	a4,a5,3
    8000508e:	00e03733          	snez	a4,a4
    80005092:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005096:	4007f793          	andi	a5,a5,1024
    8000509a:	c791                	beqz	a5,800050a6 <sys_open+0xb8>
    8000509c:	04449703          	lh	a4,68(s1)
    800050a0:	4789                	li	a5,2
    800050a2:	08f70d63          	beq	a4,a5,8000513c <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800050a6:	8526                	mv	a0,s1
    800050a8:	a14fe0ef          	jal	800032bc <iunlock>
  end_op();
    800050ac:	bdffe0ef          	jal	80003c8a <end_op>

  return fd;
    800050b0:	854e                	mv	a0,s3
    800050b2:	74aa                	ld	s1,168(sp)
    800050b4:	790a                	ld	s2,160(sp)
    800050b6:	69ea                	ld	s3,152(sp)
}
    800050b8:	70ea                	ld	ra,184(sp)
    800050ba:	744a                	ld	s0,176(sp)
    800050bc:	6129                	addi	sp,sp,192
    800050be:	8082                	ret
      end_op();
    800050c0:	bcbfe0ef          	jal	80003c8a <end_op>
      return -1;
    800050c4:	557d                	li	a0,-1
    800050c6:	74aa                	ld	s1,168(sp)
    800050c8:	bfc5                	j	800050b8 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800050ca:	f5040513          	addi	a0,s0,-176
    800050ce:	96ffe0ef          	jal	80003a3c <namei>
    800050d2:	84aa                	mv	s1,a0
    800050d4:	c11d                	beqz	a0,800050fa <sys_open+0x10c>
    ilock(ip);
    800050d6:	938fe0ef          	jal	8000320e <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800050da:	04449703          	lh	a4,68(s1)
    800050de:	4785                	li	a5,1
    800050e0:	f4f71ce3          	bne	a4,a5,80005038 <sys_open+0x4a>
    800050e4:	f4c42783          	lw	a5,-180(s0)
    800050e8:	d3b5                	beqz	a5,8000504c <sys_open+0x5e>
      iunlockput(ip);
    800050ea:	8526                	mv	a0,s1
    800050ec:	b2efe0ef          	jal	8000341a <iunlockput>
      end_op();
    800050f0:	b9bfe0ef          	jal	80003c8a <end_op>
      return -1;
    800050f4:	557d                	li	a0,-1
    800050f6:	74aa                	ld	s1,168(sp)
    800050f8:	b7c1                	j	800050b8 <sys_open+0xca>
      end_op();
    800050fa:	b91fe0ef          	jal	80003c8a <end_op>
      return -1;
    800050fe:	557d                	li	a0,-1
    80005100:	74aa                	ld	s1,168(sp)
    80005102:	bf5d                	j	800050b8 <sys_open+0xca>
    iunlockput(ip);
    80005104:	8526                	mv	a0,s1
    80005106:	b14fe0ef          	jal	8000341a <iunlockput>
    end_op();
    8000510a:	b81fe0ef          	jal	80003c8a <end_op>
    return -1;
    8000510e:	557d                	li	a0,-1
    80005110:	74aa                	ld	s1,168(sp)
    80005112:	b75d                	j	800050b8 <sys_open+0xca>
      fileclose(f);
    80005114:	854a                	mv	a0,s2
    80005116:	f87fe0ef          	jal	8000409c <fileclose>
    8000511a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000511c:	8526                	mv	a0,s1
    8000511e:	afcfe0ef          	jal	8000341a <iunlockput>
    end_op();
    80005122:	b69fe0ef          	jal	80003c8a <end_op>
    return -1;
    80005126:	557d                	li	a0,-1
    80005128:	74aa                	ld	s1,168(sp)
    8000512a:	790a                	ld	s2,160(sp)
    8000512c:	b771                	j	800050b8 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000512e:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005132:	04649783          	lh	a5,70(s1)
    80005136:	02f91223          	sh	a5,36(s2)
    8000513a:	bf35                	j	80005076 <sys_open+0x88>
    itrunc(ip);
    8000513c:	8526                	mv	a0,s1
    8000513e:	9befe0ef          	jal	800032fc <itrunc>
    80005142:	b795                	j	800050a6 <sys_open+0xb8>

0000000080005144 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005144:	7175                	addi	sp,sp,-144
    80005146:	e506                	sd	ra,136(sp)
    80005148:	e122                	sd	s0,128(sp)
    8000514a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000514c:	acffe0ef          	jal	80003c1a <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005150:	08000613          	li	a2,128
    80005154:	f7040593          	addi	a1,s0,-144
    80005158:	4501                	li	a0,0
    8000515a:	ef2fd0ef          	jal	8000284c <argstr>
    8000515e:	02054363          	bltz	a0,80005184 <sys_mkdir+0x40>
    80005162:	4681                	li	a3,0
    80005164:	4601                	li	a2,0
    80005166:	4585                	li	a1,1
    80005168:	f7040513          	addi	a0,s0,-144
    8000516c:	973ff0ef          	jal	80004ade <create>
    80005170:	c911                	beqz	a0,80005184 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005172:	aa8fe0ef          	jal	8000341a <iunlockput>
  end_op();
    80005176:	b15fe0ef          	jal	80003c8a <end_op>
  return 0;
    8000517a:	4501                	li	a0,0
}
    8000517c:	60aa                	ld	ra,136(sp)
    8000517e:	640a                	ld	s0,128(sp)
    80005180:	6149                	addi	sp,sp,144
    80005182:	8082                	ret
    end_op();
    80005184:	b07fe0ef          	jal	80003c8a <end_op>
    return -1;
    80005188:	557d                	li	a0,-1
    8000518a:	bfcd                	j	8000517c <sys_mkdir+0x38>

000000008000518c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000518c:	7135                	addi	sp,sp,-160
    8000518e:	ed06                	sd	ra,152(sp)
    80005190:	e922                	sd	s0,144(sp)
    80005192:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005194:	a87fe0ef          	jal	80003c1a <begin_op>
  argint(1, &major);
    80005198:	f6c40593          	addi	a1,s0,-148
    8000519c:	4505                	li	a0,1
    8000519e:	e76fd0ef          	jal	80002814 <argint>
  argint(2, &minor);
    800051a2:	f6840593          	addi	a1,s0,-152
    800051a6:	4509                	li	a0,2
    800051a8:	e6cfd0ef          	jal	80002814 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800051ac:	08000613          	li	a2,128
    800051b0:	f7040593          	addi	a1,s0,-144
    800051b4:	4501                	li	a0,0
    800051b6:	e96fd0ef          	jal	8000284c <argstr>
    800051ba:	02054563          	bltz	a0,800051e4 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800051be:	f6841683          	lh	a3,-152(s0)
    800051c2:	f6c41603          	lh	a2,-148(s0)
    800051c6:	458d                	li	a1,3
    800051c8:	f7040513          	addi	a0,s0,-144
    800051cc:	913ff0ef          	jal	80004ade <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800051d0:	c911                	beqz	a0,800051e4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051d2:	a48fe0ef          	jal	8000341a <iunlockput>
  end_op();
    800051d6:	ab5fe0ef          	jal	80003c8a <end_op>
  return 0;
    800051da:	4501                	li	a0,0
}
    800051dc:	60ea                	ld	ra,152(sp)
    800051de:	644a                	ld	s0,144(sp)
    800051e0:	610d                	addi	sp,sp,160
    800051e2:	8082                	ret
    end_op();
    800051e4:	aa7fe0ef          	jal	80003c8a <end_op>
    return -1;
    800051e8:	557d                	li	a0,-1
    800051ea:	bfcd                	j	800051dc <sys_mknod+0x50>

00000000800051ec <sys_chdir>:

uint64
sys_chdir(void)
{
    800051ec:	7135                	addi	sp,sp,-160
    800051ee:	ed06                	sd	ra,152(sp)
    800051f0:	e922                	sd	s0,144(sp)
    800051f2:	e14a                	sd	s2,128(sp)
    800051f4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800051f6:	f0cfc0ef          	jal	80001902 <myproc>
    800051fa:	892a                	mv	s2,a0

  begin_op();
    800051fc:	a1ffe0ef          	jal	80003c1a <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005200:	08000613          	li	a2,128
    80005204:	f6040593          	addi	a1,s0,-160
    80005208:	4501                	li	a0,0
    8000520a:	e42fd0ef          	jal	8000284c <argstr>
    8000520e:	04054363          	bltz	a0,80005254 <sys_chdir+0x68>
    80005212:	e526                	sd	s1,136(sp)
    80005214:	f6040513          	addi	a0,s0,-160
    80005218:	825fe0ef          	jal	80003a3c <namei>
    8000521c:	84aa                	mv	s1,a0
    8000521e:	c915                	beqz	a0,80005252 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005220:	feffd0ef          	jal	8000320e <ilock>
  if (ip->type != T_DIR) {
    80005224:	04449703          	lh	a4,68(s1)
    80005228:	4785                	li	a5,1
    8000522a:	02f71963          	bne	a4,a5,8000525c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000522e:	8526                	mv	a0,s1
    80005230:	88cfe0ef          	jal	800032bc <iunlock>
  iput(p->cwd);
    80005234:	15093503          	ld	a0,336(s2)
    80005238:	958fe0ef          	jal	80003390 <iput>
  end_op();
    8000523c:	a4ffe0ef          	jal	80003c8a <end_op>
  p->cwd = ip;
    80005240:	14993823          	sd	s1,336(s2)
  return 0;
    80005244:	4501                	li	a0,0
    80005246:	64aa                	ld	s1,136(sp)
}
    80005248:	60ea                	ld	ra,152(sp)
    8000524a:	644a                	ld	s0,144(sp)
    8000524c:	690a                	ld	s2,128(sp)
    8000524e:	610d                	addi	sp,sp,160
    80005250:	8082                	ret
    80005252:	64aa                	ld	s1,136(sp)
    end_op();
    80005254:	a37fe0ef          	jal	80003c8a <end_op>
    return -1;
    80005258:	557d                	li	a0,-1
    8000525a:	b7fd                	j	80005248 <sys_chdir+0x5c>
    iunlockput(ip);
    8000525c:	8526                	mv	a0,s1
    8000525e:	9bcfe0ef          	jal	8000341a <iunlockput>
    end_op();
    80005262:	a29fe0ef          	jal	80003c8a <end_op>
    return -1;
    80005266:	557d                	li	a0,-1
    80005268:	64aa                	ld	s1,136(sp)
    8000526a:	bff9                	j	80005248 <sys_chdir+0x5c>

000000008000526c <sys_exec>:

uint64
sys_exec(void)
{
    8000526c:	7105                	addi	sp,sp,-480
    8000526e:	ef86                	sd	ra,472(sp)
    80005270:	eba2                	sd	s0,464(sp)
    80005272:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005274:	e2840593          	addi	a1,s0,-472
    80005278:	4505                	li	a0,1
    8000527a:	db6fd0ef          	jal	80002830 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000527e:	08000613          	li	a2,128
    80005282:	f3040593          	addi	a1,s0,-208
    80005286:	4501                	li	a0,0
    80005288:	dc4fd0ef          	jal	8000284c <argstr>
    8000528c:	87aa                	mv	a5,a0
    return -1;
    8000528e:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005290:	0e07c063          	bltz	a5,80005370 <sys_exec+0x104>
    80005294:	e7a6                	sd	s1,456(sp)
    80005296:	e3ca                	sd	s2,448(sp)
    80005298:	ff4e                	sd	s3,440(sp)
    8000529a:	fb52                	sd	s4,432(sp)
    8000529c:	f756                	sd	s5,424(sp)
    8000529e:	f35a                	sd	s6,416(sp)
    800052a0:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800052a2:	e3040a13          	addi	s4,s0,-464
    800052a6:	10000613          	li	a2,256
    800052aa:	4581                	li	a1,0
    800052ac:	8552                	mv	a0,s4
    800052ae:	a1ffb0ef          	jal	80000ccc <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800052b2:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800052b4:	89d2                	mv	s3,s4
    800052b6:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800052b8:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052bc:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800052be:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800052c2:	00391513          	slli	a0,s2,0x3
    800052c6:	85d6                	mv	a1,s5
    800052c8:	e2843783          	ld	a5,-472(s0)
    800052cc:	953e                	add	a0,a0,a5
    800052ce:	cbcfd0ef          	jal	8000278a <fetchaddr>
    800052d2:	02054663          	bltz	a0,800052fe <sys_exec+0x92>
    if (uarg == 0) {
    800052d6:	e2043783          	ld	a5,-480(s0)
    800052da:	c7a1                	beqz	a5,80005322 <sys_exec+0xb6>
    argv[i] = kalloc();
    800052dc:	845fb0ef          	jal	80000b20 <kalloc>
    800052e0:	85aa                	mv	a1,a0
    800052e2:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800052e6:	cd01                	beqz	a0,800052fe <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052e8:	865a                	mv	a2,s6
    800052ea:	e2043503          	ld	a0,-480(s0)
    800052ee:	ce6fd0ef          	jal	800027d4 <fetchstr>
    800052f2:	00054663          	bltz	a0,800052fe <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800052f6:	0905                	addi	s2,s2,1
    800052f8:	09a1                	addi	s3,s3,8
    800052fa:	fd7914e3          	bne	s2,s7,800052c2 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052fe:	100a0a13          	addi	s4,s4,256
    80005302:	6088                	ld	a0,0(s1)
    80005304:	cd31                	beqz	a0,80005360 <sys_exec+0xf4>
    kfree(argv[i]);
    80005306:	f32fb0ef          	jal	80000a38 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000530a:	04a1                	addi	s1,s1,8
    8000530c:	ff449be3          	bne	s1,s4,80005302 <sys_exec+0x96>
  return -1;
    80005310:	557d                	li	a0,-1
    80005312:	64be                	ld	s1,456(sp)
    80005314:	691e                	ld	s2,448(sp)
    80005316:	79fa                	ld	s3,440(sp)
    80005318:	7a5a                	ld	s4,432(sp)
    8000531a:	7aba                	ld	s5,424(sp)
    8000531c:	7b1a                	ld	s6,416(sp)
    8000531e:	6bfa                	ld	s7,408(sp)
    80005320:	a881                	j	80005370 <sys_exec+0x104>
      argv[i] = 0;
    80005322:	0009079b          	sext.w	a5,s2
    80005326:	e3040593          	addi	a1,s0,-464
    8000532a:	078e                	slli	a5,a5,0x3
    8000532c:	97ae                	add	a5,a5,a1
    8000532e:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005332:	f3040513          	addi	a0,s0,-208
    80005336:	bb2ff0ef          	jal	800046e8 <kexec>
    8000533a:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000533c:	100a0a13          	addi	s4,s4,256
    80005340:	6088                	ld	a0,0(s1)
    80005342:	c511                	beqz	a0,8000534e <sys_exec+0xe2>
    kfree(argv[i]);
    80005344:	ef4fb0ef          	jal	80000a38 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005348:	04a1                	addi	s1,s1,8
    8000534a:	ff449be3          	bne	s1,s4,80005340 <sys_exec+0xd4>
  return ret;
    8000534e:	854a                	mv	a0,s2
    80005350:	64be                	ld	s1,456(sp)
    80005352:	691e                	ld	s2,448(sp)
    80005354:	79fa                	ld	s3,440(sp)
    80005356:	7a5a                	ld	s4,432(sp)
    80005358:	7aba                	ld	s5,424(sp)
    8000535a:	7b1a                	ld	s6,416(sp)
    8000535c:	6bfa                	ld	s7,408(sp)
    8000535e:	a809                	j	80005370 <sys_exec+0x104>
  return -1;
    80005360:	557d                	li	a0,-1
    80005362:	64be                	ld	s1,456(sp)
    80005364:	691e                	ld	s2,448(sp)
    80005366:	79fa                	ld	s3,440(sp)
    80005368:	7a5a                	ld	s4,432(sp)
    8000536a:	7aba                	ld	s5,424(sp)
    8000536c:	7b1a                	ld	s6,416(sp)
    8000536e:	6bfa                	ld	s7,408(sp)
}
    80005370:	60fe                	ld	ra,472(sp)
    80005372:	645e                	ld	s0,464(sp)
    80005374:	613d                	addi	sp,sp,480
    80005376:	8082                	ret

0000000080005378 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005378:	7139                	addi	sp,sp,-64
    8000537a:	fc06                	sd	ra,56(sp)
    8000537c:	f822                	sd	s0,48(sp)
    8000537e:	f426                	sd	s1,40(sp)
    80005380:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005382:	d80fc0ef          	jal	80001902 <myproc>
    80005386:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005388:	fd840593          	addi	a1,s0,-40
    8000538c:	4501                	li	a0,0
    8000538e:	ca2fd0ef          	jal	80002830 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005392:	fc840593          	addi	a1,s0,-56
    80005396:	fd040513          	addi	a0,s0,-48
    8000539a:	81eff0ef          	jal	800043b8 <pipealloc>
    return -1;
    8000539e:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800053a0:	0a054763          	bltz	a0,8000544e <sys_pipe+0xd6>
  fd0 = -1;
    800053a4:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800053a8:	fd043503          	ld	a0,-48(s0)
    800053ac:	ef2ff0ef          	jal	80004a9e <fdalloc>
    800053b0:	fca42223          	sw	a0,-60(s0)
    800053b4:	08054463          	bltz	a0,8000543c <sys_pipe+0xc4>
    800053b8:	fc843503          	ld	a0,-56(s0)
    800053bc:	ee2ff0ef          	jal	80004a9e <fdalloc>
    800053c0:	fca42023          	sw	a0,-64(s0)
    800053c4:	06054263          	bltz	a0,80005428 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800053c8:	4691                	li	a3,4
    800053ca:	fc440613          	addi	a2,s0,-60
    800053ce:	fd843583          	ld	a1,-40(s0)
    800053d2:	68a8                	ld	a0,80(s1)
    800053d4:	a54fc0ef          	jal	80001628 <copyout>
    800053d8:	00054e63          	bltz	a0,800053f4 <sys_pipe+0x7c>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) <
    800053dc:	4691                	li	a3,4
    800053de:	fc040613          	addi	a2,s0,-64
    800053e2:	fd843583          	ld	a1,-40(s0)
    800053e6:	95b6                	add	a1,a1,a3
    800053e8:	68a8                	ld	a0,80(s1)
    800053ea:	a3efc0ef          	jal	80001628 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800053ee:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800053f0:	04055f63          	bgez	a0,8000544e <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    800053f4:	fc442783          	lw	a5,-60(s0)
    800053f8:	078e                	slli	a5,a5,0x3
    800053fa:	0d078793          	addi	a5,a5,208
    800053fe:	97a6                	add	a5,a5,s1
    80005400:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005404:	fc042783          	lw	a5,-64(s0)
    80005408:	078e                	slli	a5,a5,0x3
    8000540a:	0d078793          	addi	a5,a5,208
    8000540e:	97a6                	add	a5,a5,s1
    80005410:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005414:	fd043503          	ld	a0,-48(s0)
    80005418:	c85fe0ef          	jal	8000409c <fileclose>
    fileclose(wf);
    8000541c:	fc843503          	ld	a0,-56(s0)
    80005420:	c7dfe0ef          	jal	8000409c <fileclose>
    return -1;
    80005424:	57fd                	li	a5,-1
    80005426:	a025                	j	8000544e <sys_pipe+0xd6>
    if (fd0 >= 0)
    80005428:	fc442783          	lw	a5,-60(s0)
    8000542c:	0007c863          	bltz	a5,8000543c <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005430:	078e                	slli	a5,a5,0x3
    80005432:	0d078793          	addi	a5,a5,208
    80005436:	97a6                	add	a5,a5,s1
    80005438:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000543c:	fd043503          	ld	a0,-48(s0)
    80005440:	c5dfe0ef          	jal	8000409c <fileclose>
    fileclose(wf);
    80005444:	fc843503          	ld	a0,-56(s0)
    80005448:	c55fe0ef          	jal	8000409c <fileclose>
    return -1;
    8000544c:	57fd                	li	a5,-1
}
    8000544e:	853e                	mv	a0,a5
    80005450:	70e2                	ld	ra,56(sp)
    80005452:	7442                	ld	s0,48(sp)
    80005454:	74a2                	ld	s1,40(sp)
    80005456:	6121                	addi	sp,sp,64
    80005458:	8082                	ret
    8000545a:	0000                	unimp
    8000545c:	0000                	unimp
	...

0000000080005460 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005460:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005462:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005464:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005466:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005468:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000546a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000546c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000546e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005470:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005472:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005474:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005476:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005478:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000547a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000547c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000547e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005480:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005482:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005484:	a14fd0ef          	jal	80002698 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005488:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000548a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000548c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000548e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005490:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005492:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005494:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005496:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005498:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000549a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000549c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000549e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054a0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054a2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054a4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054a6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054a8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054aa:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054ac:	10200073          	sret
    800054b0:	0001                	nop
    800054b2:	00000013          	nop
    800054b6:	00000013          	nop
    800054ba:	00000013          	nop

00000000800054be <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800054be:	1141                	addi	sp,sp,-16
    800054c0:	e406                	sd	ra,8(sp)
    800054c2:	e022                	sd	s0,0(sp)
    800054c4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800054c6:	0c000737          	lui	a4,0xc000
    800054ca:	4785                	li	a5,1
    800054cc:	d71c                	sw	a5,40(a4)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800054ce:	c35c                	sw	a5,4(a4)
}
    800054d0:	60a2                	ld	ra,8(sp)
    800054d2:	6402                	ld	s0,0(sp)
    800054d4:	0141                	addi	sp,sp,16
    800054d6:	8082                	ret

00000000800054d8 <plicinithart>:

void
plicinithart(void)
{
    800054d8:	1141                	addi	sp,sp,-16
    800054da:	e406                	sd	ra,8(sp)
    800054dc:	e022                	sd	s0,0(sp)
    800054de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054e0:	beefc0ef          	jal	800018ce <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800054e4:	0085171b          	slliw	a4,a0,0x8
    800054e8:	0c0027b7          	lui	a5,0xc002
    800054ec:	97ba                	add	a5,a5,a4
    800054ee:	40200713          	li	a4,1026
    800054f2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    800054f6:	00d5151b          	slliw	a0,a0,0xd
    800054fa:	0c2017b7          	lui	a5,0xc201
    800054fe:	97aa                	add	a5,a5,a0
    80005500:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005504:	60a2                	ld	ra,8(sp)
    80005506:	6402                	ld	s0,0(sp)
    80005508:	0141                	addi	sp,sp,16
    8000550a:	8082                	ret

000000008000550c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000550c:	1141                	addi	sp,sp,-16
    8000550e:	e406                	sd	ra,8(sp)
    80005510:	e022                	sd	s0,0(sp)
    80005512:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005514:	bbafc0ef          	jal	800018ce <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005518:	00d5151b          	slliw	a0,a0,0xd
    8000551c:	0c2017b7          	lui	a5,0xc201
    80005520:	97aa                	add	a5,a5,a0
  return irq;
}
    80005522:	43c8                	lw	a0,4(a5)
    80005524:	60a2                	ld	ra,8(sp)
    80005526:	6402                	ld	s0,0(sp)
    80005528:	0141                	addi	sp,sp,16
    8000552a:	8082                	ret

000000008000552c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000552c:	1101                	addi	sp,sp,-32
    8000552e:	ec06                	sd	ra,24(sp)
    80005530:	e822                	sd	s0,16(sp)
    80005532:	e426                	sd	s1,8(sp)
    80005534:	1000                	addi	s0,sp,32
    80005536:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005538:	b96fc0ef          	jal	800018ce <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    8000553c:	00d5179b          	slliw	a5,a0,0xd
    80005540:	0c201737          	lui	a4,0xc201
    80005544:	97ba                	add	a5,a5,a4
    80005546:	c3c4                	sw	s1,4(a5)
}
    80005548:	60e2                	ld	ra,24(sp)
    8000554a:	6442                	ld	s0,16(sp)
    8000554c:	64a2                	ld	s1,8(sp)
    8000554e:	6105                	addi	sp,sp,32
    80005550:	8082                	ret

0000000080005552 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005552:	1141                	addi	sp,sp,-16
    80005554:	e406                	sd	ra,8(sp)
    80005556:	e022                	sd	s0,0(sp)
    80005558:	0800                	addi	s0,sp,16
  if (i >= NUM)
    8000555a:	479d                	li	a5,7
    8000555c:	04a7ca63          	blt	a5,a0,800055b0 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005560:	0001e797          	auipc	a5,0x1e
    80005564:	f1878793          	addi	a5,a5,-232 # 80023478 <disk>
    80005568:	97aa                	add	a5,a5,a0
    8000556a:	0187c783          	lbu	a5,24(a5)
    8000556e:	e7b9                	bnez	a5,800055bc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005570:	00451693          	slli	a3,a0,0x4
    80005574:	0001e797          	auipc	a5,0x1e
    80005578:	f0478793          	addi	a5,a5,-252 # 80023478 <disk>
    8000557c:	6398                	ld	a4,0(a5)
    8000557e:	9736                	add	a4,a4,a3
    80005580:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005584:	6398                	ld	a4,0(a5)
    80005586:	9736                	add	a4,a4,a3
    80005588:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000558c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005590:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005594:	97aa                	add	a5,a5,a0
    80005596:	4705                	li	a4,1
    80005598:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000559c:	0001e517          	auipc	a0,0x1e
    800055a0:	ef450513          	addi	a0,a0,-268 # 80023490 <disk+0x18>
    800055a4:	9b1fc0ef          	jal	80001f54 <wakeup>
}
    800055a8:	60a2                	ld	ra,8(sp)
    800055aa:	6402                	ld	s0,0(sp)
    800055ac:	0141                	addi	sp,sp,16
    800055ae:	8082                	ret
    panic("free_desc 1");
    800055b0:	00002517          	auipc	a0,0x2
    800055b4:	06050513          	addi	a0,a0,96 # 80007610 <etext+0x610>
    800055b8:	a60fb0ef          	jal	80000818 <panic>
    panic("free_desc 2");
    800055bc:	00002517          	auipc	a0,0x2
    800055c0:	06450513          	addi	a0,a0,100 # 80007620 <etext+0x620>
    800055c4:	a54fb0ef          	jal	80000818 <panic>

00000000800055c8 <virtio_disk_init>:
{
    800055c8:	1101                	addi	sp,sp,-32
    800055ca:	ec06                	sd	ra,24(sp)
    800055cc:	e822                	sd	s0,16(sp)
    800055ce:	e426                	sd	s1,8(sp)
    800055d0:	e04a                	sd	s2,0(sp)
    800055d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055d4:	00002597          	auipc	a1,0x2
    800055d8:	05c58593          	addi	a1,a1,92 # 80007630 <etext+0x630>
    800055dc:	0001e517          	auipc	a0,0x1e
    800055e0:	fc450513          	addi	a0,a0,-60 # 800235a0 <disk+0x128>
    800055e4:	d96fb0ef          	jal	80000b7a <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055e8:	100017b7          	lui	a5,0x10001
    800055ec:	4398                	lw	a4,0(a5)
    800055ee:	2701                	sext.w	a4,a4
    800055f0:	747277b7          	lui	a5,0x74727
    800055f4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800055f8:	14f71863          	bne	a4,a5,80005748 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055fc:	100017b7          	lui	a5,0x10001
    80005600:	43dc                	lw	a5,4(a5)
    80005602:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005604:	4709                	li	a4,2
    80005606:	14e79163          	bne	a5,a4,80005748 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000560a:	100017b7          	lui	a5,0x10001
    8000560e:	479c                	lw	a5,8(a5)
    80005610:	2781                	sext.w	a5,a5
    80005612:	12e79b63          	bne	a5,a4,80005748 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005616:	100017b7          	lui	a5,0x10001
    8000561a:	47d8                	lw	a4,12(a5)
    8000561c:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000561e:	554d47b7          	lui	a5,0x554d4
    80005622:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005626:	12f71163          	bne	a4,a5,80005748 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000562a:	100017b7          	lui	a5,0x10001
    8000562e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005632:	4705                	li	a4,1
    80005634:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005636:	470d                	li	a4,3
    80005638:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000563a:	10001737          	lui	a4,0x10001
    8000563e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005640:	c7ffe6b7          	lui	a3,0xc7ffe
    80005644:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb1a7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005648:	8f75                	and	a4,a4,a3
    8000564a:	100016b7          	lui	a3,0x10001
    8000564e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005650:	472d                	li	a4,11
    80005652:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005654:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005658:	439c                	lw	a5,0(a5)
    8000565a:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000565e:	8ba1                	andi	a5,a5,8
    80005660:	0e078a63          	beqz	a5,80005754 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005664:	100017b7          	lui	a5,0x10001
    80005668:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    8000566c:	43fc                	lw	a5,68(a5)
    8000566e:	2781                	sext.w	a5,a5
    80005670:	0e079863          	bnez	a5,80005760 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005674:	100017b7          	lui	a5,0x10001
    80005678:	5bdc                	lw	a5,52(a5)
    8000567a:	2781                	sext.w	a5,a5
  if (max == 0)
    8000567c:	0e078863          	beqz	a5,8000576c <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005680:	471d                	li	a4,7
    80005682:	0ef77b63          	bgeu	a4,a5,80005778 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005686:	c9afb0ef          	jal	80000b20 <kalloc>
    8000568a:	0001e497          	auipc	s1,0x1e
    8000568e:	dee48493          	addi	s1,s1,-530 # 80023478 <disk>
    80005692:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005694:	c8cfb0ef          	jal	80000b20 <kalloc>
    80005698:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000569a:	c86fb0ef          	jal	80000b20 <kalloc>
    8000569e:	87aa                	mv	a5,a0
    800056a0:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800056a2:	6088                	ld	a0,0(s1)
    800056a4:	0e050063          	beqz	a0,80005784 <virtio_disk_init+0x1bc>
    800056a8:	0001e717          	auipc	a4,0x1e
    800056ac:	dd873703          	ld	a4,-552(a4) # 80023480 <disk+0x8>
    800056b0:	cb71                	beqz	a4,80005784 <virtio_disk_init+0x1bc>
    800056b2:	cbe9                	beqz	a5,80005784 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800056b4:	6605                	lui	a2,0x1
    800056b6:	4581                	li	a1,0
    800056b8:	e14fb0ef          	jal	80000ccc <memset>
  memset(disk.avail, 0, PGSIZE);
    800056bc:	0001e497          	auipc	s1,0x1e
    800056c0:	dbc48493          	addi	s1,s1,-580 # 80023478 <disk>
    800056c4:	6605                	lui	a2,0x1
    800056c6:	4581                	li	a1,0
    800056c8:	6488                	ld	a0,8(s1)
    800056ca:	e02fb0ef          	jal	80000ccc <memset>
  memset(disk.used, 0, PGSIZE);
    800056ce:	6605                	lui	a2,0x1
    800056d0:	4581                	li	a1,0
    800056d2:	6888                	ld	a0,16(s1)
    800056d4:	df8fb0ef          	jal	80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056d8:	100017b7          	lui	a5,0x10001
    800056dc:	4721                	li	a4,8
    800056de:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800056e0:	4098                	lw	a4,0(s1)
    800056e2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056e6:	40d8                	lw	a4,4(s1)
    800056e8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056ec:	649c                	ld	a5,8(s1)
    800056ee:	0007869b          	sext.w	a3,a5
    800056f2:	10001737          	lui	a4,0x10001
    800056f6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800056fa:	9781                	srai	a5,a5,0x20
    800056fc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005700:	689c                	ld	a5,16(s1)
    80005702:	0007869b          	sext.w	a3,a5
    80005706:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000570a:	9781                	srai	a5,a5,0x20
    8000570c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005710:	4785                	li	a5,1
    80005712:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005714:	00f48c23          	sb	a5,24(s1)
    80005718:	00f48ca3          	sb	a5,25(s1)
    8000571c:	00f48d23          	sb	a5,26(s1)
    80005720:	00f48da3          	sb	a5,27(s1)
    80005724:	00f48e23          	sb	a5,28(s1)
    80005728:	00f48ea3          	sb	a5,29(s1)
    8000572c:	00f48f23          	sb	a5,30(s1)
    80005730:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005734:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005738:	07272823          	sw	s2,112(a4)
}
    8000573c:	60e2                	ld	ra,24(sp)
    8000573e:	6442                	ld	s0,16(sp)
    80005740:	64a2                	ld	s1,8(sp)
    80005742:	6902                	ld	s2,0(sp)
    80005744:	6105                	addi	sp,sp,32
    80005746:	8082                	ret
    panic("could not find virtio disk");
    80005748:	00002517          	auipc	a0,0x2
    8000574c:	ef850513          	addi	a0,a0,-264 # 80007640 <etext+0x640>
    80005750:	8c8fb0ef          	jal	80000818 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005754:	00002517          	auipc	a0,0x2
    80005758:	f0c50513          	addi	a0,a0,-244 # 80007660 <etext+0x660>
    8000575c:	8bcfb0ef          	jal	80000818 <panic>
    panic("virtio disk should not be ready");
    80005760:	00002517          	auipc	a0,0x2
    80005764:	f2050513          	addi	a0,a0,-224 # 80007680 <etext+0x680>
    80005768:	8b0fb0ef          	jal	80000818 <panic>
    panic("virtio disk has no queue 0");
    8000576c:	00002517          	auipc	a0,0x2
    80005770:	f3450513          	addi	a0,a0,-204 # 800076a0 <etext+0x6a0>
    80005774:	8a4fb0ef          	jal	80000818 <panic>
    panic("virtio disk max queue too short");
    80005778:	00002517          	auipc	a0,0x2
    8000577c:	f4850513          	addi	a0,a0,-184 # 800076c0 <etext+0x6c0>
    80005780:	898fb0ef          	jal	80000818 <panic>
    panic("virtio disk kalloc");
    80005784:	00002517          	auipc	a0,0x2
    80005788:	f5c50513          	addi	a0,a0,-164 # 800076e0 <etext+0x6e0>
    8000578c:	88cfb0ef          	jal	80000818 <panic>

0000000080005790 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005790:	711d                	addi	sp,sp,-96
    80005792:	ec86                	sd	ra,88(sp)
    80005794:	e8a2                	sd	s0,80(sp)
    80005796:	e4a6                	sd	s1,72(sp)
    80005798:	e0ca                	sd	s2,64(sp)
    8000579a:	fc4e                	sd	s3,56(sp)
    8000579c:	f852                	sd	s4,48(sp)
    8000579e:	f456                	sd	s5,40(sp)
    800057a0:	f05a                	sd	s6,32(sp)
    800057a2:	ec5e                	sd	s7,24(sp)
    800057a4:	e862                	sd	s8,16(sp)
    800057a6:	1080                	addi	s0,sp,96
    800057a8:	89aa                	mv	s3,a0
    800057aa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057ac:	00c52b83          	lw	s7,12(a0)
    800057b0:	001b9b9b          	slliw	s7,s7,0x1
    800057b4:	1b82                	slli	s7,s7,0x20
    800057b6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800057ba:	0001e517          	auipc	a0,0x1e
    800057be:	de650513          	addi	a0,a0,-538 # 800235a0 <disk+0x128>
    800057c2:	c42fb0ef          	jal	80000c04 <acquire>
  for (int i = 0; i < NUM; i++) {
    800057c6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057c8:	0001ea97          	auipc	s5,0x1e
    800057cc:	cb0a8a93          	addi	s5,s5,-848 # 80023478 <disk>
  for (int i = 0; i < 3; i++) {
    800057d0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800057d2:	5c7d                	li	s8,-1
    800057d4:	a095                	j	80005838 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800057d6:	00fa8733          	add	a4,s5,a5
    800057da:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800057de:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    800057e0:	0207c563          	bltz	a5,8000580a <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    800057e4:	2905                	addiw	s2,s2,1
    800057e6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800057e8:	05490c63          	beq	s2,s4,80005840 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800057ec:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    800057ee:	0001e717          	auipc	a4,0x1e
    800057f2:	c8a70713          	addi	a4,a4,-886 # 80023478 <disk>
    800057f6:	4781                	li	a5,0
    if (disk.free[i]) {
    800057f8:	01874683          	lbu	a3,24(a4)
    800057fc:	fee9                	bnez	a3,800057d6 <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    800057fe:	2785                	addiw	a5,a5,1
    80005800:	0705                	addi	a4,a4,1
    80005802:	fe979be3          	bne	a5,s1,800057f8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005806:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    8000580a:	01205d63          	blez	s2,80005824 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000580e:	fa042503          	lw	a0,-96(s0)
    80005812:	d41ff0ef          	jal	80005552 <free_desc>
      for (int j = 0; j < i; j++)
    80005816:	4785                	li	a5,1
    80005818:	0127d663          	bge	a5,s2,80005824 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000581c:	fa442503          	lw	a0,-92(s0)
    80005820:	d33ff0ef          	jal	80005552 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005824:	0001e597          	auipc	a1,0x1e
    80005828:	d7c58593          	addi	a1,a1,-644 # 800235a0 <disk+0x128>
    8000582c:	0001e517          	auipc	a0,0x1e
    80005830:	c6450513          	addi	a0,a0,-924 # 80023490 <disk+0x18>
    80005834:	ed4fc0ef          	jal	80001f08 <sleep>
  for (int i = 0; i < 3; i++) {
    80005838:	fa040613          	addi	a2,s0,-96
    8000583c:	4901                	li	s2,0
    8000583e:	b77d                	j	800057ec <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005840:	fa042503          	lw	a0,-96(s0)
    80005844:	00451693          	slli	a3,a0,0x4

  if (write)
    80005848:	0001e797          	auipc	a5,0x1e
    8000584c:	c3078793          	addi	a5,a5,-976 # 80023478 <disk>
    80005850:	00451713          	slli	a4,a0,0x4
    80005854:	0a070713          	addi	a4,a4,160
    80005858:	973e                	add	a4,a4,a5
    8000585a:	01603633          	snez	a2,s6
    8000585e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005860:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005864:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005868:	6398                	ld	a4,0(a5)
    8000586a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000586c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005870:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005872:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005874:	6390                	ld	a2,0(a5)
    80005876:	00d60833          	add	a6,a2,a3
    8000587a:	4741                	li	a4,16
    8000587c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005880:	4585                	li	a1,1
    80005882:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005886:	fa442703          	lw	a4,-92(s0)
    8000588a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    8000588e:	0712                	slli	a4,a4,0x4
    80005890:	963a                	add	a2,a2,a4
    80005892:	05898813          	addi	a6,s3,88
    80005896:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000589a:	0007b883          	ld	a7,0(a5)
    8000589e:	9746                	add	a4,a4,a7
    800058a0:	40000613          	li	a2,1024
    800058a4:	c710                	sw	a2,8(a4)
  if (write)
    800058a6:	001b3613          	seqz	a2,s6
    800058aa:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058ae:	8e4d                	or	a2,a2,a1
    800058b0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800058b4:	fa842603          	lw	a2,-88(s0)
    800058b8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058bc:	00451813          	slli	a6,a0,0x4
    800058c0:	02080813          	addi	a6,a6,32
    800058c4:	983e                	add	a6,a6,a5
    800058c6:	577d                	li	a4,-1
    800058c8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    800058cc:	0612                	slli	a2,a2,0x4
    800058ce:	98b2                	add	a7,a7,a2
    800058d0:	03068713          	addi	a4,a3,48
    800058d4:	973e                	add	a4,a4,a5
    800058d6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800058da:	6398                	ld	a4,0(a5)
    800058dc:	9732                	add	a4,a4,a2
    800058de:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800058e0:	4689                	li	a3,2
    800058e2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800058e6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058ea:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    800058ee:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800058f2:	6794                	ld	a3,8(a5)
    800058f4:	0026d703          	lhu	a4,2(a3)
    800058f8:	8b1d                	andi	a4,a4,7
    800058fa:	0706                	slli	a4,a4,0x1
    800058fc:	96ba                	add	a3,a3,a4
    800058fe:	00a69223          	sh	a0,4(a3)

  __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80005902:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005906:	6798                	ld	a4,8(a5)
    80005908:	00275783          	lhu	a5,2(a4)
    8000590c:	2785                	addiw	a5,a5,1
    8000590e:	00f71123          	sh	a5,2(a4)

  __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80005912:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005916:	100017b7          	lui	a5,0x10001
    8000591a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    8000591e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005922:	0001e917          	auipc	s2,0x1e
    80005926:	c7e90913          	addi	s2,s2,-898 # 800235a0 <disk+0x128>
  while (b->disk == 1) {
    8000592a:	84ae                	mv	s1,a1
    8000592c:	00b79a63          	bne	a5,a1,80005940 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005930:	85ca                	mv	a1,s2
    80005932:	854e                	mv	a0,s3
    80005934:	dd4fc0ef          	jal	80001f08 <sleep>
  while (b->disk == 1) {
    80005938:	0049a783          	lw	a5,4(s3)
    8000593c:	fe978ae3          	beq	a5,s1,80005930 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005940:	fa042903          	lw	s2,-96(s0)
    80005944:	00491713          	slli	a4,s2,0x4
    80005948:	02070713          	addi	a4,a4,32
    8000594c:	0001e797          	auipc	a5,0x1e
    80005950:	b2c78793          	addi	a5,a5,-1236 # 80023478 <disk>
    80005954:	97ba                	add	a5,a5,a4
    80005956:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000595a:	0001e997          	auipc	s3,0x1e
    8000595e:	b1e98993          	addi	s3,s3,-1250 # 80023478 <disk>
    80005962:	00491713          	slli	a4,s2,0x4
    80005966:	0009b783          	ld	a5,0(s3)
    8000596a:	97ba                	add	a5,a5,a4
    8000596c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005970:	854a                	mv	a0,s2
    80005972:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005976:	bddff0ef          	jal	80005552 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    8000597a:	8885                	andi	s1,s1,1
    8000597c:	f0fd                	bnez	s1,80005962 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000597e:	0001e517          	auipc	a0,0x1e
    80005982:	c2250513          	addi	a0,a0,-990 # 800235a0 <disk+0x128>
    80005986:	b0efb0ef          	jal	80000c94 <release>
}
    8000598a:	60e6                	ld	ra,88(sp)
    8000598c:	6446                	ld	s0,80(sp)
    8000598e:	64a6                	ld	s1,72(sp)
    80005990:	6906                	ld	s2,64(sp)
    80005992:	79e2                	ld	s3,56(sp)
    80005994:	7a42                	ld	s4,48(sp)
    80005996:	7aa2                	ld	s5,40(sp)
    80005998:	7b02                	ld	s6,32(sp)
    8000599a:	6be2                	ld	s7,24(sp)
    8000599c:	6c42                	ld	s8,16(sp)
    8000599e:	6125                	addi	sp,sp,96
    800059a0:	8082                	ret

00000000800059a2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059a2:	1101                	addi	sp,sp,-32
    800059a4:	ec06                	sd	ra,24(sp)
    800059a6:	e822                	sd	s0,16(sp)
    800059a8:	e426                	sd	s1,8(sp)
    800059aa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059ac:	0001e497          	auipc	s1,0x1e
    800059b0:	acc48493          	addi	s1,s1,-1332 # 80023478 <disk>
    800059b4:	0001e517          	auipc	a0,0x1e
    800059b8:	bec50513          	addi	a0,a0,-1044 # 800235a0 <disk+0x128>
    800059bc:	a48fb0ef          	jal	80000c04 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059c0:	100017b7          	lui	a5,0x10001
    800059c4:	53bc                	lw	a5,96(a5)
    800059c6:	8b8d                	andi	a5,a5,3
    800059c8:	10001737          	lui	a4,0x10001
    800059cc:	d37c                	sw	a5,100(a4)

  __atomic_thread_fence(__ATOMIC_SEQ_CST);
    800059ce:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    800059d2:	689c                	ld	a5,16(s1)
    800059d4:	0204d703          	lhu	a4,32(s1)
    800059d8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800059dc:	04f70863          	beq	a4,a5,80005a2c <virtio_disk_intr+0x8a>
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    800059e0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059e4:	6898                	ld	a4,16(s1)
    800059e6:	0204d783          	lhu	a5,32(s1)
    800059ea:	8b9d                	andi	a5,a5,7
    800059ec:	078e                	slli	a5,a5,0x3
    800059ee:	97ba                	add	a5,a5,a4
    800059f0:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    800059f2:	00479713          	slli	a4,a5,0x4
    800059f6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    800059fa:	9726                	add	a4,a4,s1
    800059fc:	01074703          	lbu	a4,16(a4)
    80005a00:	e329                	bnez	a4,80005a42 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a02:	0792                	slli	a5,a5,0x4
    80005a04:	02078793          	addi	a5,a5,32
    80005a08:	97a6                	add	a5,a5,s1
    80005a0a:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005a0c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a10:	d44fc0ef          	jal	80001f54 <wakeup>

    disk.used_idx += 1;
    80005a14:	0204d783          	lhu	a5,32(s1)
    80005a18:	2785                	addiw	a5,a5,1
    80005a1a:	17c2                	slli	a5,a5,0x30
    80005a1c:	93c1                	srli	a5,a5,0x30
    80005a1e:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005a22:	6898                	ld	a4,16(s1)
    80005a24:	00275703          	lhu	a4,2(a4)
    80005a28:	faf71ce3          	bne	a4,a5,800059e0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a2c:	0001e517          	auipc	a0,0x1e
    80005a30:	b7450513          	addi	a0,a0,-1164 # 800235a0 <disk+0x128>
    80005a34:	a60fb0ef          	jal	80000c94 <release>
}
    80005a38:	60e2                	ld	ra,24(sp)
    80005a3a:	6442                	ld	s0,16(sp)
    80005a3c:	64a2                	ld	s1,8(sp)
    80005a3e:	6105                	addi	sp,sp,32
    80005a40:	8082                	ret
      panic("virtio_disk_intr status");
    80005a42:	00002517          	auipc	a0,0x2
    80005a46:	cb650513          	addi	a0,a0,-842 # 800076f8 <etext+0x6f8>
    80005a4a:	dcffa0ef          	jal	80000818 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
