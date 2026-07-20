
user/_sync:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  sync();
   8:	360000ef          	jal	368 <sync>
  exit(0);
   c:	4501                	li	a0,0
   e:	2ba000ef          	jal	2c8 <exit>

0000000000000012 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  12:	1141                	addi	sp,sp,-16
  14:	e406                	sd	ra,8(sp)
  16:	e022                	sd	s0,0(sp)
  18:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  1a:	fe7ff0ef          	jal	0 <main>
  exit(r);
  1e:	2aa000ef          	jal	2c8 <exit>

0000000000000022 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  22:	1141                	addi	sp,sp,-16
  24:	e406                	sd	ra,8(sp)
  26:	e022                	sd	s0,0(sp)
  28:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  2a:	87aa                	mv	a5,a0
  2c:	0585                	addi	a1,a1,1
  2e:	0785                	addi	a5,a5,1
  30:	fff5c703          	lbu	a4,-1(a1)
  34:	fee78fa3          	sb	a4,-1(a5)
  38:	fb75                	bnez	a4,2c <strcpy+0xa>
    ;
  return os;
}
  3a:	60a2                	ld	ra,8(sp)
  3c:	6402                	ld	s0,0(sp)
  3e:	0141                	addi	sp,sp,16
  40:	8082                	ret

0000000000000042 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  42:	1141                	addi	sp,sp,-16
  44:	e406                	sd	ra,8(sp)
  46:	e022                	sd	s0,0(sp)
  48:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  4a:	00054783          	lbu	a5,0(a0)
  4e:	cb91                	beqz	a5,62 <strcmp+0x20>
  50:	0005c703          	lbu	a4,0(a1)
  54:	00f71763          	bne	a4,a5,62 <strcmp+0x20>
    p++, q++;
  58:	0505                	addi	a0,a0,1
  5a:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  5c:	00054783          	lbu	a5,0(a0)
  60:	fbe5                	bnez	a5,50 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  62:	0005c503          	lbu	a0,0(a1)
}
  66:	40a7853b          	subw	a0,a5,a0
  6a:	60a2                	ld	ra,8(sp)
  6c:	6402                	ld	s0,0(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strlen>:

uint
strlen(const char *s)
{
  72:	1141                	addi	sp,sp,-16
  74:	e406                	sd	ra,8(sp)
  76:	e022                	sd	s0,0(sp)
  78:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	cf91                	beqz	a5,9a <strlen+0x28>
  80:	00150793          	addi	a5,a0,1
  84:	86be                	mv	a3,a5
  86:	0785                	addi	a5,a5,1
  88:	fff7c703          	lbu	a4,-1(a5)
  8c:	ff65                	bnez	a4,84 <strlen+0x12>
  8e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  92:	60a2                	ld	ra,8(sp)
  94:	6402                	ld	s0,0(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret
  for (n = 0; s[n]; n++)
  9a:	4501                	li	a0,0
  9c:	bfdd                	j	92 <strlen+0x20>

000000000000009e <memset>:

void *
memset(void *dst, int c, uint n)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e406                	sd	ra,8(sp)
  a2:	e022                	sd	s0,0(sp)
  a4:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
  a6:	ca19                	beqz	a2,bc <memset+0x1e>
  a8:	87aa                	mv	a5,a0
  aa:	1602                	slli	a2,a2,0x20
  ac:	9201                	srli	a2,a2,0x20
  ae:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b2:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
  b6:	0785                	addi	a5,a5,1
  b8:	fee79de3          	bne	a5,a4,b2 <memset+0x14>
  }
  return dst;
}
  bc:	60a2                	ld	ra,8(sp)
  be:	6402                	ld	s0,0(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strchr>:

char *
strchr(const char *s, char c)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e406                	sd	ra,8(sp)
  c8:	e022                	sd	s0,0(sp)
  ca:	0800                	addi	s0,sp,16
  for (; *s; s++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cf81                	beqz	a5,e8 <strchr+0x24>
    if (*s == c)
  d2:	00f58763          	beq	a1,a5,e0 <strchr+0x1c>
  for (; *s; s++)
  d6:	0505                	addi	a0,a0,1
  d8:	00054783          	lbu	a5,0(a0)
  dc:	fbfd                	bnez	a5,d2 <strchr+0xe>
      return (char *)s;
  return 0;
  de:	4501                	li	a0,0
}
  e0:	60a2                	ld	ra,8(sp)
  e2:	6402                	ld	s0,0(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret
  return 0;
  e8:	4501                	li	a0,0
  ea:	bfdd                	j	e0 <strchr+0x1c>

00000000000000ec <gets>:

char *
gets(char *buf, int max)
{
  ec:	711d                	addi	sp,sp,-96
  ee:	ec86                	sd	ra,88(sp)
  f0:	e8a2                	sd	s0,80(sp)
  f2:	e4a6                	sd	s1,72(sp)
  f4:	e0ca                	sd	s2,64(sp)
  f6:	fc4e                	sd	s3,56(sp)
  f8:	f852                	sd	s4,48(sp)
  fa:	f456                	sd	s5,40(sp)
  fc:	f05a                	sd	s6,32(sp)
  fe:	ec5e                	sd	s7,24(sp)
 100:	e862                	sd	s8,16(sp)
 102:	1080                	addi	s0,sp,96
 104:	8baa                	mv	s7,a0
 106:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 108:	892a                	mv	s2,a0
 10a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 10c:	faf40b13          	addi	s6,s0,-81
 110:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 112:	8c26                	mv	s8,s1
 114:	0014899b          	addiw	s3,s1,1
 118:	84ce                	mv	s1,s3
 11a:	0349d463          	bge	s3,s4,142 <gets+0x56>
    cc = read(0, &c, 1);
 11e:	8656                	mv	a2,s5
 120:	85da                	mv	a1,s6
 122:	4501                	li	a0,0
 124:	1bc000ef          	jal	2e0 <read>
    if (cc < 1)
 128:	00a05d63          	blez	a0,142 <gets+0x56>
      break;
    buf[i++] = c;
 12c:	faf44783          	lbu	a5,-81(s0)
 130:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 134:	0905                	addi	s2,s2,1
 136:	ff678713          	addi	a4,a5,-10
 13a:	c319                	beqz	a4,140 <gets+0x54>
 13c:	17cd                	addi	a5,a5,-13
 13e:	fbf1                	bnez	a5,112 <gets+0x26>
    buf[i++] = c;
 140:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 142:	9c5e                	add	s8,s8,s7
 144:	000c0023          	sb	zero,0(s8)
  return buf;
}
 148:	855e                	mv	a0,s7
 14a:	60e6                	ld	ra,88(sp)
 14c:	6446                	ld	s0,80(sp)
 14e:	64a6                	ld	s1,72(sp)
 150:	6906                	ld	s2,64(sp)
 152:	79e2                	ld	s3,56(sp)
 154:	7a42                	ld	s4,48(sp)
 156:	7aa2                	ld	s5,40(sp)
 158:	7b02                	ld	s6,32(sp)
 15a:	6be2                	ld	s7,24(sp)
 15c:	6c42                	ld	s8,16(sp)
 15e:	6125                	addi	sp,sp,96
 160:	8082                	ret

0000000000000162 <stat>:

int
stat(const char *n, struct stat *st)
{
 162:	1101                	addi	sp,sp,-32
 164:	ec06                	sd	ra,24(sp)
 166:	e822                	sd	s0,16(sp)
 168:	e04a                	sd	s2,0(sp)
 16a:	1000                	addi	s0,sp,32
 16c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 16e:	4581                	li	a1,0
 170:	198000ef          	jal	308 <open>
  if (fd < 0)
 174:	02054263          	bltz	a0,198 <stat+0x36>
 178:	e426                	sd	s1,8(sp)
 17a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 17c:	85ca                	mv	a1,s2
 17e:	1a2000ef          	jal	320 <fstat>
 182:	892a                	mv	s2,a0
  close(fd);
 184:	8526                	mv	a0,s1
 186:	16a000ef          	jal	2f0 <close>
  return r;
 18a:	64a2                	ld	s1,8(sp)
}
 18c:	854a                	mv	a0,s2
 18e:	60e2                	ld	ra,24(sp)
 190:	6442                	ld	s0,16(sp)
 192:	6902                	ld	s2,0(sp)
 194:	6105                	addi	sp,sp,32
 196:	8082                	ret
    return -1;
 198:	57fd                	li	a5,-1
 19a:	893e                	mv	s2,a5
 19c:	bfc5                	j	18c <stat+0x2a>

000000000000019e <atoi>:

int
atoi(const char *s)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e406                	sd	ra,8(sp)
 1a2:	e022                	sd	s0,0(sp)
 1a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 1a6:	00054683          	lbu	a3,0(a0)
 1aa:	fd06879b          	addiw	a5,a3,-48
 1ae:	0ff7f793          	zext.b	a5,a5
 1b2:	4625                	li	a2,9
 1b4:	02f66963          	bltu	a2,a5,1e6 <atoi+0x48>
 1b8:	872a                	mv	a4,a0
  n = 0;
 1ba:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 1bc:	0705                	addi	a4,a4,1
 1be:	0025179b          	slliw	a5,a0,0x2
 1c2:	9fa9                	addw	a5,a5,a0
 1c4:	0017979b          	slliw	a5,a5,0x1
 1c8:	9fb5                	addw	a5,a5,a3
 1ca:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 1ce:	00074683          	lbu	a3,0(a4)
 1d2:	fd06879b          	addiw	a5,a3,-48
 1d6:	0ff7f793          	zext.b	a5,a5
 1da:	fef671e3          	bgeu	a2,a5,1bc <atoi+0x1e>
  return n;
}
 1de:	60a2                	ld	ra,8(sp)
 1e0:	6402                	ld	s0,0(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret
  n = 0;
 1e6:	4501                	li	a0,0
 1e8:	bfdd                	j	1de <atoi+0x40>

00000000000001ea <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e406                	sd	ra,8(sp)
 1ee:	e022                	sd	s0,0(sp)
 1f0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f2:	02b57563          	bgeu	a0,a1,21c <memmove+0x32>
    while (n-- > 0)
 1f6:	00c05f63          	blez	a2,214 <memmove+0x2a>
 1fa:	1602                	slli	a2,a2,0x20
 1fc:	9201                	srli	a2,a2,0x20
 1fe:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 202:	872a                	mv	a4,a0
      *dst++ = *src++;
 204:	0585                	addi	a1,a1,1
 206:	0705                	addi	a4,a4,1
 208:	fff5c683          	lbu	a3,-1(a1)
 20c:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 210:	fee79ae3          	bne	a5,a4,204 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 214:	60a2                	ld	ra,8(sp)
 216:	6402                	ld	s0,0(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
    while (n-- > 0)
 21c:	fec05ce3          	blez	a2,214 <memmove+0x2a>
    dst += n;
 220:	00c50733          	add	a4,a0,a2
    src += n;
 224:	95b2                	add	a1,a1,a2
 226:	fff6079b          	addiw	a5,a2,-1
 22a:	1782                	slli	a5,a5,0x20
 22c:	9381                	srli	a5,a5,0x20
 22e:	fff7c793          	not	a5,a5
 232:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 234:	15fd                	addi	a1,a1,-1
 236:	177d                	addi	a4,a4,-1
 238:	0005c683          	lbu	a3,0(a1)
 23c:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 240:	fef71ae3          	bne	a4,a5,234 <memmove+0x4a>
 244:	bfc1                	j	214 <memmove+0x2a>

0000000000000246 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 246:	1141                	addi	sp,sp,-16
 248:	e406                	sd	ra,8(sp)
 24a:	e022                	sd	s0,0(sp)
 24c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24e:	c61d                	beqz	a2,27c <memcmp+0x36>
 250:	1602                	slli	a2,a2,0x20
 252:	9201                	srli	a2,a2,0x20
 254:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 258:	00054783          	lbu	a5,0(a0)
 25c:	0005c703          	lbu	a4,0(a1)
 260:	00e79863          	bne	a5,a4,270 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 264:	0505                	addi	a0,a0,1
    p2++;
 266:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 268:	fed518e3          	bne	a0,a3,258 <memcmp+0x12>
  }
  return 0;
 26c:	4501                	li	a0,0
 26e:	a019                	j	274 <memcmp+0x2e>
      return *p1 - *p2;
 270:	40e7853b          	subw	a0,a5,a4
}
 274:	60a2                	ld	ra,8(sp)
 276:	6402                	ld	s0,0(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret
  return 0;
 27c:	4501                	li	a0,0
 27e:	bfdd                	j	274 <memcmp+0x2e>

0000000000000280 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 280:	1141                	addi	sp,sp,-16
 282:	e406                	sd	ra,8(sp)
 284:	e022                	sd	s0,0(sp)
 286:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 288:	f63ff0ef          	jal	1ea <memmove>
}
 28c:	60a2                	ld	ra,8(sp)
 28e:	6402                	ld	s0,0(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <sbrk>:

char *
sbrk(int n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e406                	sd	ra,8(sp)
 298:	e022                	sd	s0,0(sp)
 29a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 29c:	4585                	li	a1,1
 29e:	0b2000ef          	jal	350 <sys_sbrk>
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <sbrklazy>:

char *
sbrklazy(int n)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2b2:	4589                	li	a1,2
 2b4:	09c000ef          	jal	350 <sys_sbrk>
}
 2b8:	60a2                	ld	ra,8(sp)
 2ba:	6402                	ld	s0,0(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2c0:	4885                	li	a7,1
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c8:	4889                	li	a7,2
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2d0:	488d                	li	a7,3
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d8:	4891                	li	a7,4
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <read>:
.global read
read:
 li a7, SYS_read
 2e0:	4895                	li	a7,5
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <write>:
.global write
write:
 li a7, SYS_write
 2e8:	48c1                	li	a7,16
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <close>:
.global close
close:
 li a7, SYS_close
 2f0:	48d5                	li	a7,21
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f8:	4899                	li	a7,6
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <exec>:
.global exec
exec:
 li a7, SYS_exec
 300:	489d                	li	a7,7
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <open>:
.global open
open:
 li a7, SYS_open
 308:	48bd                	li	a7,15
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 310:	48c5                	li	a7,17
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 318:	48c9                	li	a7,18
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 320:	48a1                	li	a7,8
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <link>:
.global link
link:
 li a7, SYS_link
 328:	48cd                	li	a7,19
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 330:	48d1                	li	a7,20
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 338:	48a5                	li	a7,9
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <dup>:
.global dup
dup:
 li a7, SYS_dup
 340:	48a9                	li	a7,10
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 348:	48ad                	li	a7,11
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 350:	48b1                	li	a7,12
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <pause>:
.global pause
pause:
 li a7, SYS_pause
 358:	48b5                	li	a7,13
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 360:	48b9                	li	a7,14
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <sync>:
.global sync
sync:
 li a7, SYS_sync
 368:	48d9                	li	a7,22
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <getidade>:
.global getidade
getidade:
 li a7, SYS_getidade
 370:	48dd                	li	a7,23
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 378:	48e1                	li	a7,24
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 380:	1101                	addi	sp,sp,-32
 382:	ec06                	sd	ra,24(sp)
 384:	e822                	sd	s0,16(sp)
 386:	1000                	addi	s0,sp,32
 388:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 38c:	4605                	li	a2,1
 38e:	fef40593          	addi	a1,s0,-17
 392:	f57ff0ef          	jal	2e8 <write>
}
 396:	60e2                	ld	ra,24(sp)
 398:	6442                	ld	s0,16(sp)
 39a:	6105                	addi	sp,sp,32
 39c:	8082                	ret

000000000000039e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 39e:	715d                	addi	sp,sp,-80
 3a0:	e486                	sd	ra,72(sp)
 3a2:	e0a2                	sd	s0,64(sp)
 3a4:	f84a                	sd	s2,48(sp)
 3a6:	f44e                	sd	s3,40(sp)
 3a8:	0880                	addi	s0,sp,80
 3aa:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 3ac:	c6d1                	beqz	a3,438 <printint+0x9a>
 3ae:	0805d563          	bgez	a1,438 <printint+0x9a>
    neg = 1;
    x = -xx;
 3b2:	40b005b3          	neg	a1,a1
    neg = 1;
 3b6:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3b8:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3bc:	86ce                	mv	a3,s3
  i = 0;
 3be:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 3c0:	00000817          	auipc	a6,0x0
 3c4:	51880813          	addi	a6,a6,1304 # 8d8 <digits>
 3c8:	88ba                	mv	a7,a4
 3ca:	0017051b          	addiw	a0,a4,1
 3ce:	872a                	mv	a4,a0
 3d0:	02c5f7b3          	remu	a5,a1,a2
 3d4:	97c2                	add	a5,a5,a6
 3d6:	0007c783          	lbu	a5,0(a5)
 3da:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 3de:	87ae                	mv	a5,a1
 3e0:	02c5d5b3          	divu	a1,a1,a2
 3e4:	0685                	addi	a3,a3,1
 3e6:	fec7f1e3          	bgeu	a5,a2,3c8 <printint+0x2a>
  if (neg)
 3ea:	00030c63          	beqz	t1,402 <printint+0x64>
    buf[i++] = '-';
 3ee:	fd050793          	addi	a5,a0,-48
 3f2:	00878533          	add	a0,a5,s0
 3f6:	02d00793          	li	a5,45
 3fa:	fef50423          	sb	a5,-24(a0)
 3fe:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 402:	02e05563          	blez	a4,42c <printint+0x8e>
 406:	fc26                	sd	s1,56(sp)
 408:	377d                	addiw	a4,a4,-1
 40a:	00e984b3          	add	s1,s3,a4
 40e:	19fd                	addi	s3,s3,-1
 410:	99ba                	add	s3,s3,a4
 412:	1702                	slli	a4,a4,0x20
 414:	9301                	srli	a4,a4,0x20
 416:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 41a:	0004c583          	lbu	a1,0(s1)
 41e:	854a                	mv	a0,s2
 420:	f61ff0ef          	jal	380 <putc>
  while (--i >= 0)
 424:	14fd                	addi	s1,s1,-1
 426:	ff349ae3          	bne	s1,s3,41a <printint+0x7c>
 42a:	74e2                	ld	s1,56(sp)
}
 42c:	60a6                	ld	ra,72(sp)
 42e:	6406                	ld	s0,64(sp)
 430:	7942                	ld	s2,48(sp)
 432:	79a2                	ld	s3,40(sp)
 434:	6161                	addi	sp,sp,80
 436:	8082                	ret
  neg = 0;
 438:	4301                	li	t1,0
 43a:	bfbd                	j	3b8 <printint+0x1a>

000000000000043c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43c:	711d                	addi	sp,sp,-96
 43e:	ec86                	sd	ra,88(sp)
 440:	e8a2                	sd	s0,80(sp)
 442:	e4a6                	sd	s1,72(sp)
 444:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 446:	0005c483          	lbu	s1,0(a1)
 44a:	22048363          	beqz	s1,670 <vprintf+0x234>
 44e:	e0ca                	sd	s2,64(sp)
 450:	fc4e                	sd	s3,56(sp)
 452:	f852                	sd	s4,48(sp)
 454:	f456                	sd	s5,40(sp)
 456:	f05a                	sd	s6,32(sp)
 458:	ec5e                	sd	s7,24(sp)
 45a:	e862                	sd	s8,16(sp)
 45c:	8b2a                	mv	s6,a0
 45e:	8a2e                	mv	s4,a1
 460:	8bb2                	mv	s7,a2
  state = 0;
 462:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 464:	4901                	li	s2,0
 466:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 468:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 46c:	06400c13          	li	s8,100
 470:	a00d                	j	492 <vprintf+0x56>
        putc(fd, c0);
 472:	85a6                	mv	a1,s1
 474:	855a                	mv	a0,s6
 476:	f0bff0ef          	jal	380 <putc>
 47a:	a019                	j	480 <vprintf+0x44>
    } else if (state == '%') {
 47c:	03598363          	beq	s3,s5,4a2 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 480:	0019079b          	addiw	a5,s2,1
 484:	893e                	mv	s2,a5
 486:	873e                	mv	a4,a5
 488:	97d2                	add	a5,a5,s4
 48a:	0007c483          	lbu	s1,0(a5)
 48e:	1c048a63          	beqz	s1,662 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 492:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 496:	fe0993e3          	bnez	s3,47c <vprintf+0x40>
      if (c0 == '%') {
 49a:	fd579ce3          	bne	a5,s5,472 <vprintf+0x36>
        state = '%';
 49e:	89be                	mv	s3,a5
 4a0:	b7c5                	j	480 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 4a2:	00ea06b3          	add	a3,s4,a4
 4a6:	0016c603          	lbu	a2,1(a3)
      if (c1)
 4aa:	1c060863          	beqz	a2,67a <vprintf+0x23e>
      if (c0 == 'd') {
 4ae:	03878763          	beq	a5,s8,4dc <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 4b2:	f9478693          	addi	a3,a5,-108
 4b6:	0016b693          	seqz	a3,a3
 4ba:	f9c60593          	addi	a1,a2,-100
 4be:	e99d                	bnez	a1,4f4 <vprintf+0xb8>
 4c0:	ca95                	beqz	a3,4f4 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4c2:	008b8493          	addi	s1,s7,8
 4c6:	4685                	li	a3,1
 4c8:	4629                	li	a2,10
 4ca:	000bb583          	ld	a1,0(s7)
 4ce:	855a                	mv	a0,s6
 4d0:	ecfff0ef          	jal	39e <printint>
        i += 1;
 4d4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 4d6:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4d8:	4981                	li	s3,0
 4da:	b75d                	j	480 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 4dc:	008b8493          	addi	s1,s7,8
 4e0:	4685                	li	a3,1
 4e2:	4629                	li	a2,10
 4e4:	000ba583          	lw	a1,0(s7)
 4e8:	855a                	mv	a0,s6
 4ea:	eb5ff0ef          	jal	39e <printint>
 4ee:	8ba6                	mv	s7,s1
      state = 0;
 4f0:	4981                	li	s3,0
 4f2:	b779                	j	480 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 4f4:	9752                	add	a4,a4,s4
 4f6:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 4fa:	f9460713          	addi	a4,a2,-108
 4fe:	00173713          	seqz	a4,a4
 502:	8f75                	and	a4,a4,a3
 504:	f9c58513          	addi	a0,a1,-100
 508:	18051363          	bnez	a0,68e <vprintf+0x252>
 50c:	18070163          	beqz	a4,68e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 510:	008b8493          	addi	s1,s7,8
 514:	4685                	li	a3,1
 516:	4629                	li	a2,10
 518:	000bb583          	ld	a1,0(s7)
 51c:	855a                	mv	a0,s6
 51e:	e81ff0ef          	jal	39e <printint>
        i += 2;
 522:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 524:	8ba6                	mv	s7,s1
      state = 0;
 526:	4981                	li	s3,0
        i += 2;
 528:	bfa1                	j	480 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 52a:	008b8493          	addi	s1,s7,8
 52e:	4681                	li	a3,0
 530:	4629                	li	a2,10
 532:	000be583          	lwu	a1,0(s7)
 536:	855a                	mv	a0,s6
 538:	e67ff0ef          	jal	39e <printint>
 53c:	8ba6                	mv	s7,s1
      state = 0;
 53e:	4981                	li	s3,0
 540:	b781                	j	480 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 542:	008b8493          	addi	s1,s7,8
 546:	4681                	li	a3,0
 548:	4629                	li	a2,10
 54a:	000bb583          	ld	a1,0(s7)
 54e:	855a                	mv	a0,s6
 550:	e4fff0ef          	jal	39e <printint>
        i += 1;
 554:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 556:	8ba6                	mv	s7,s1
      state = 0;
 558:	4981                	li	s3,0
 55a:	b71d                	j	480 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 55c:	008b8493          	addi	s1,s7,8
 560:	4681                	li	a3,0
 562:	4629                	li	a2,10
 564:	000bb583          	ld	a1,0(s7)
 568:	855a                	mv	a0,s6
 56a:	e35ff0ef          	jal	39e <printint>
        i += 2;
 56e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 570:	8ba6                	mv	s7,s1
      state = 0;
 572:	4981                	li	s3,0
        i += 2;
 574:	b731                	j	480 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 576:	008b8493          	addi	s1,s7,8
 57a:	4681                	li	a3,0
 57c:	4641                	li	a2,16
 57e:	000be583          	lwu	a1,0(s7)
 582:	855a                	mv	a0,s6
 584:	e1bff0ef          	jal	39e <printint>
 588:	8ba6                	mv	s7,s1
      state = 0;
 58a:	4981                	li	s3,0
 58c:	bdd5                	j	480 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 58e:	008b8493          	addi	s1,s7,8
 592:	4681                	li	a3,0
 594:	4641                	li	a2,16
 596:	000bb583          	ld	a1,0(s7)
 59a:	855a                	mv	a0,s6
 59c:	e03ff0ef          	jal	39e <printint>
        i += 1;
 5a0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5a2:	8ba6                	mv	s7,s1
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	bde9                	j	480 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5a8:	008b8493          	addi	s1,s7,8
 5ac:	4681                	li	a3,0
 5ae:	4641                	li	a2,16
 5b0:	000bb583          	ld	a1,0(s7)
 5b4:	855a                	mv	a0,s6
 5b6:	de9ff0ef          	jal	39e <printint>
        i += 2;
 5ba:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5bc:	8ba6                	mv	s7,s1
      state = 0;
 5be:	4981                	li	s3,0
        i += 2;
 5c0:	b5c1                	j	480 <vprintf+0x44>
 5c2:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 5c4:	008b8793          	addi	a5,s7,8
 5c8:	8cbe                	mv	s9,a5
 5ca:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5ce:	03000593          	li	a1,48
 5d2:	855a                	mv	a0,s6
 5d4:	dadff0ef          	jal	380 <putc>
  putc(fd, 'x');
 5d8:	07800593          	li	a1,120
 5dc:	855a                	mv	a0,s6
 5de:	da3ff0ef          	jal	380 <putc>
 5e2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e4:	00000b97          	auipc	s7,0x0
 5e8:	2f4b8b93          	addi	s7,s7,756 # 8d8 <digits>
 5ec:	03c9d793          	srli	a5,s3,0x3c
 5f0:	97de                	add	a5,a5,s7
 5f2:	0007c583          	lbu	a1,0(a5)
 5f6:	855a                	mv	a0,s6
 5f8:	d89ff0ef          	jal	380 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5fc:	0992                	slli	s3,s3,0x4
 5fe:	34fd                	addiw	s1,s1,-1
 600:	f4f5                	bnez	s1,5ec <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 602:	8be6                	mv	s7,s9
      state = 0;
 604:	4981                	li	s3,0
 606:	6ca2                	ld	s9,8(sp)
 608:	bda5                	j	480 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 60a:	008b8493          	addi	s1,s7,8
 60e:	000bc583          	lbu	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	d6dff0ef          	jal	380 <putc>
 618:	8ba6                	mv	s7,s1
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b595                	j	480 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 61e:	008b8993          	addi	s3,s7,8
 622:	000bb483          	ld	s1,0(s7)
 626:	cc91                	beqz	s1,642 <vprintf+0x206>
        for (; *s; s++)
 628:	0004c583          	lbu	a1,0(s1)
 62c:	c985                	beqz	a1,65c <vprintf+0x220>
          putc(fd, *s);
 62e:	855a                	mv	a0,s6
 630:	d51ff0ef          	jal	380 <putc>
        for (; *s; s++)
 634:	0485                	addi	s1,s1,1
 636:	0004c583          	lbu	a1,0(s1)
 63a:	f9f5                	bnez	a1,62e <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 63c:	8bce                	mv	s7,s3
      state = 0;
 63e:	4981                	li	s3,0
 640:	b581                	j	480 <vprintf+0x44>
          s = "(null)";
 642:	00000497          	auipc	s1,0x0
 646:	28e48493          	addi	s1,s1,654 # 8d0 <malloc+0xf2>
        for (; *s; s++)
 64a:	02800593          	li	a1,40
 64e:	b7c5                	j	62e <vprintf+0x1f2>
        putc(fd, '%');
 650:	85be                	mv	a1,a5
 652:	855a                	mv	a0,s6
 654:	d2dff0ef          	jal	380 <putc>
      state = 0;
 658:	4981                	li	s3,0
 65a:	b51d                	j	480 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 65c:	8bce                	mv	s7,s3
      state = 0;
 65e:	4981                	li	s3,0
 660:	b505                	j	480 <vprintf+0x44>
 662:	6906                	ld	s2,64(sp)
 664:	79e2                	ld	s3,56(sp)
 666:	7a42                	ld	s4,48(sp)
 668:	7aa2                	ld	s5,40(sp)
 66a:	7b02                	ld	s6,32(sp)
 66c:	6be2                	ld	s7,24(sp)
 66e:	6c42                	ld	s8,16(sp)
    }
  }
}
 670:	60e6                	ld	ra,88(sp)
 672:	6446                	ld	s0,80(sp)
 674:	64a6                	ld	s1,72(sp)
 676:	6125                	addi	sp,sp,96
 678:	8082                	ret
      if (c0 == 'd') {
 67a:	06400713          	li	a4,100
 67e:	e4e78fe3          	beq	a5,a4,4dc <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 682:	f9478693          	addi	a3,a5,-108
 686:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 68a:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 68c:	4701                	li	a4,0
      } else if (c0 == 'u') {
 68e:	07500513          	li	a0,117
 692:	e8a78ce3          	beq	a5,a0,52a <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 696:	f8b60513          	addi	a0,a2,-117
 69a:	e119                	bnez	a0,6a0 <vprintf+0x264>
 69c:	ea0693e3          	bnez	a3,542 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 6a0:	f8b58513          	addi	a0,a1,-117
 6a4:	e119                	bnez	a0,6aa <vprintf+0x26e>
 6a6:	ea071be3          	bnez	a4,55c <vprintf+0x120>
      } else if (c0 == 'x') {
 6aa:	07800513          	li	a0,120
 6ae:	eca784e3          	beq	a5,a0,576 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 6b2:	f8860613          	addi	a2,a2,-120
 6b6:	e219                	bnez	a2,6bc <vprintf+0x280>
 6b8:	ec069be3          	bnez	a3,58e <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 6bc:	f8858593          	addi	a1,a1,-120
 6c0:	e199                	bnez	a1,6c6 <vprintf+0x28a>
 6c2:	ee0713e3          	bnez	a4,5a8 <vprintf+0x16c>
      } else if (c0 == 'p') {
 6c6:	07000713          	li	a4,112
 6ca:	eee78ce3          	beq	a5,a4,5c2 <vprintf+0x186>
      } else if (c0 == 'c') {
 6ce:	06300713          	li	a4,99
 6d2:	f2e78ce3          	beq	a5,a4,60a <vprintf+0x1ce>
      } else if (c0 == 's') {
 6d6:	07300713          	li	a4,115
 6da:	f4e782e3          	beq	a5,a4,61e <vprintf+0x1e2>
      } else if (c0 == '%') {
 6de:	02500713          	li	a4,37
 6e2:	f6e787e3          	beq	a5,a4,650 <vprintf+0x214>
        putc(fd, '%');
 6e6:	02500593          	li	a1,37
 6ea:	855a                	mv	a0,s6
 6ec:	c95ff0ef          	jal	380 <putc>
        putc(fd, c0);
 6f0:	85a6                	mv	a1,s1
 6f2:	855a                	mv	a0,s6
 6f4:	c8dff0ef          	jal	380 <putc>
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b359                	j	480 <vprintf+0x44>

00000000000006fc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6fc:	715d                	addi	sp,sp,-80
 6fe:	ec06                	sd	ra,24(sp)
 700:	e822                	sd	s0,16(sp)
 702:	1000                	addi	s0,sp,32
 704:	e010                	sd	a2,0(s0)
 706:	e414                	sd	a3,8(s0)
 708:	e818                	sd	a4,16(s0)
 70a:	ec1c                	sd	a5,24(s0)
 70c:	03043023          	sd	a6,32(s0)
 710:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 714:	8622                	mv	a2,s0
 716:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 71a:	d23ff0ef          	jal	43c <vprintf>
}
 71e:	60e2                	ld	ra,24(sp)
 720:	6442                	ld	s0,16(sp)
 722:	6161                	addi	sp,sp,80
 724:	8082                	ret

0000000000000726 <printf>:

void
printf(const char *fmt, ...)
{
 726:	711d                	addi	sp,sp,-96
 728:	ec06                	sd	ra,24(sp)
 72a:	e822                	sd	s0,16(sp)
 72c:	1000                	addi	s0,sp,32
 72e:	e40c                	sd	a1,8(s0)
 730:	e810                	sd	a2,16(s0)
 732:	ec14                	sd	a3,24(s0)
 734:	f018                	sd	a4,32(s0)
 736:	f41c                	sd	a5,40(s0)
 738:	03043823          	sd	a6,48(s0)
 73c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 740:	00840613          	addi	a2,s0,8
 744:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 748:	85aa                	mv	a1,a0
 74a:	4505                	li	a0,1
 74c:	cf1ff0ef          	jal	43c <vprintf>
}
 750:	60e2                	ld	ra,24(sp)
 752:	6442                	ld	s0,16(sp)
 754:	6125                	addi	sp,sp,96
 756:	8082                	ret

0000000000000758 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 758:	1141                	addi	sp,sp,-16
 75a:	e406                	sd	ra,8(sp)
 75c:	e022                	sd	s0,0(sp)
 75e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 760:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 764:	00001797          	auipc	a5,0x1
 768:	89c7b783          	ld	a5,-1892(a5) # 1000 <freep>
 76c:	a039                	j	77a <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76e:	6398                	ld	a4,0(a5)
 770:	00e7e463          	bltu	a5,a4,778 <free+0x20>
 774:	00e6ea63          	bltu	a3,a4,788 <free+0x30>
{
 778:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77a:	fed7fae3          	bgeu	a5,a3,76e <free+0x16>
 77e:	6398                	ld	a4,0(a5)
 780:	00e6e463          	bltu	a3,a4,788 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 784:	fee7eae3          	bltu	a5,a4,778 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 788:	ff852583          	lw	a1,-8(a0)
 78c:	6390                	ld	a2,0(a5)
 78e:	02059813          	slli	a6,a1,0x20
 792:	01c85713          	srli	a4,a6,0x1c
 796:	9736                	add	a4,a4,a3
 798:	02e60563          	beq	a2,a4,7c2 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 79c:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 7a0:	4790                	lw	a2,8(a5)
 7a2:	02061593          	slli	a1,a2,0x20
 7a6:	01c5d713          	srli	a4,a1,0x1c
 7aa:	973e                	add	a4,a4,a5
 7ac:	02e68263          	beq	a3,a4,7d0 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7b0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b2:	00001717          	auipc	a4,0x1
 7b6:	84f73723          	sd	a5,-1970(a4) # 1000 <freep>
}
 7ba:	60a2                	ld	ra,8(sp)
 7bc:	6402                	ld	s0,0(sp)
 7be:	0141                	addi	sp,sp,16
 7c0:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7c2:	4618                	lw	a4,8(a2)
 7c4:	9f2d                	addw	a4,a4,a1
 7c6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ca:	6398                	ld	a4,0(a5)
 7cc:	6310                	ld	a2,0(a4)
 7ce:	b7f9                	j	79c <free+0x44>
    p->s.size += bp->s.size;
 7d0:	ff852703          	lw	a4,-8(a0)
 7d4:	9f31                	addw	a4,a4,a2
 7d6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7d8:	ff053683          	ld	a3,-16(a0)
 7dc:	bfd1                	j	7b0 <free+0x58>

00000000000007de <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 7de:	7139                	addi	sp,sp,-64
 7e0:	fc06                	sd	ra,56(sp)
 7e2:	f822                	sd	s0,48(sp)
 7e4:	f04a                	sd	s2,32(sp)
 7e6:	ec4e                	sd	s3,24(sp)
 7e8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 7ea:	02051993          	slli	s3,a0,0x20
 7ee:	0209d993          	srli	s3,s3,0x20
 7f2:	09bd                	addi	s3,s3,15
 7f4:	0049d993          	srli	s3,s3,0x4
 7f8:	2985                	addiw	s3,s3,1
 7fa:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 7fc:	00001517          	auipc	a0,0x1
 800:	80453503          	ld	a0,-2044(a0) # 1000 <freep>
 804:	c905                	beqz	a0,834 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 806:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 808:	4798                	lw	a4,8(a5)
 80a:	09377663          	bgeu	a4,s3,896 <malloc+0xb8>
 80e:	f426                	sd	s1,40(sp)
 810:	e852                	sd	s4,16(sp)
 812:	e456                	sd	s5,8(sp)
 814:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 816:	8a4e                	mv	s4,s3
 818:	6705                	lui	a4,0x1
 81a:	00e9f363          	bgeu	s3,a4,820 <malloc+0x42>
 81e:	6a05                	lui	s4,0x1
 820:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 824:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 828:	00000497          	auipc	s1,0x0
 82c:	7d848493          	addi	s1,s1,2008 # 1000 <freep>
  if (p == SBRK_ERROR)
 830:	5afd                	li	s5,-1
 832:	a83d                	j	870 <malloc+0x92>
 834:	f426                	sd	s1,40(sp)
 836:	e852                	sd	s4,16(sp)
 838:	e456                	sd	s5,8(sp)
 83a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 83c:	00000797          	auipc	a5,0x0
 840:	7d478793          	addi	a5,a5,2004 # 1010 <base>
 844:	00000717          	auipc	a4,0x0
 848:	7af73e23          	sd	a5,1980(a4) # 1000 <freep>
 84c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 84e:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 852:	b7d1                	j	816 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 854:	6398                	ld	a4,0(a5)
 856:	e118                	sd	a4,0(a0)
 858:	a899                	j	8ae <malloc+0xd0>
  hp->s.size = nu;
 85a:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 85e:	0541                	addi	a0,a0,16
 860:	ef9ff0ef          	jal	758 <free>
  return freep;
 864:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 866:	c125                	beqz	a0,8c6 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 868:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 86a:	4798                	lw	a4,8(a5)
 86c:	03277163          	bgeu	a4,s2,88e <malloc+0xb0>
    if (p == freep)
 870:	6098                	ld	a4,0(s1)
 872:	853e                	mv	a0,a5
 874:	fef71ae3          	bne	a4,a5,868 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 878:	8552                	mv	a0,s4
 87a:	a1bff0ef          	jal	294 <sbrk>
  if (p == SBRK_ERROR)
 87e:	fd551ee3          	bne	a0,s5,85a <malloc+0x7c>
        return 0;
 882:	4501                	li	a0,0
 884:	74a2                	ld	s1,40(sp)
 886:	6a42                	ld	s4,16(sp)
 888:	6aa2                	ld	s5,8(sp)
 88a:	6b02                	ld	s6,0(sp)
 88c:	a03d                	j	8ba <malloc+0xdc>
 88e:	74a2                	ld	s1,40(sp)
 890:	6a42                	ld	s4,16(sp)
 892:	6aa2                	ld	s5,8(sp)
 894:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 896:	fae90fe3          	beq	s2,a4,854 <malloc+0x76>
        p->s.size -= nunits;
 89a:	4137073b          	subw	a4,a4,s3
 89e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a0:	02071693          	slli	a3,a4,0x20
 8a4:	01c6d713          	srli	a4,a3,0x1c
 8a8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8aa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ae:	00000717          	auipc	a4,0x0
 8b2:	74a73923          	sd	a0,1874(a4) # 1000 <freep>
      return (void *)(p + 1);
 8b6:	01078513          	addi	a0,a5,16
  }
}
 8ba:	70e2                	ld	ra,56(sp)
 8bc:	7442                	ld	s0,48(sp)
 8be:	7902                	ld	s2,32(sp)
 8c0:	69e2                	ld	s3,24(sp)
 8c2:	6121                	addi	sp,sp,64
 8c4:	8082                	ret
 8c6:	74a2                	ld	s1,40(sp)
 8c8:	6a42                	ld	s4,16(sp)
 8ca:	6aa2                	ld	s5,8(sp)
 8cc:	6b02                	ld	s6,0(sp)
 8ce:	b7f5                	j	8ba <malloc+0xdc>
