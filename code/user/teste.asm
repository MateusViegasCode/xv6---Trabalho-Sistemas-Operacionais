
user/_teste:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <busy_loop>:
// Loop ocupado só para consumir CPU (sem I/O, sem sleep/pause),
// assim o processo nunca dorme e o scheduler não tem motivo pra
// tirar ele de RUNNING a não ser terminar.
void
busy_loop(long n)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  volatile long i;
  for (i = 0; i < n; i++)
   8:	fe043423          	sd	zero,-24(s0)
   c:	fe843783          	ld	a5,-24(s0)
  10:	00a7db63          	bge	a5,a0,26 <busy_loop+0x26>
  14:	fe843783          	ld	a5,-24(s0)
  18:	0785                	addi	a5,a5,1
  1a:	fef43423          	sd	a5,-24(s0)
  1e:	fe843783          	ld	a5,-24(s0)
  22:	fea7c9e3          	blt	a5,a0,14 <busy_loop+0x14>
    ;
}
  26:	60e2                	ld	ra,24(sp)
  28:	6442                	ld	s0,16(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <main>:

int
main(void)
{
  2e:	7179                	addi	sp,sp,-48
  30:	f406                	sd	ra,40(sp)
  32:	f022                	sd	s0,32(sp)
  34:	ec26                	sd	s1,24(sp)
  36:	e84a                	sd	s2,16(sp)
  38:	e44e                	sd	s3,8(sp)
  3a:	1800                	addi	s0,sp,48
  int i;

  // ---- Teste 1: getppid() ----
  printf("=== Teste 1: getppid() ===\n");
  3c:	00001517          	auipc	a0,0x1
  40:	9b450513          	addi	a0,a0,-1612 # 9f0 <malloc+0xf8>
  44:	7fc000ef          	jal	840 <printf>
  printf("Processo atual (PID): %d\n", getpid());
  48:	41a000ef          	jal	462 <getpid>
  4c:	85aa                	mv	a1,a0
  4e:	00001517          	auipc	a0,0x1
  52:	9c250513          	addi	a0,a0,-1598 # a10 <malloc+0x118>
  56:	7ea000ef          	jal	840 <printf>
  printf("Processo pai (PPID): %d\n", getppid());
  5a:	438000ef          	jal	492 <getppid>
  5e:	85aa                	mv	a1,a0
  60:	00001517          	auipc	a0,0x1
  64:	9d050513          	addi	a0,a0,-1584 # a30 <malloc+0x138>
  68:	7d8000ef          	jal	840 <printf>

  // ---- Teste 2: ordem de execucao (FCFS / RR) ----
  printf("\n=== Teste 2: Ordem de execucao ===\n");
  6c:	00001517          	auipc	a0,0x1
  70:	9e450513          	addi	a0,a0,-1564 # a50 <malloc+0x158>
  74:	7cc000ef          	jal	840 <printf>
  printf("Criando %d processos filhos...\n", NUM_FILHOS);
  78:	4591                	li	a1,4
  7a:	00001517          	auipc	a0,0x1
  7e:	9fe50513          	addi	a0,a0,-1538 # a78 <malloc+0x180>
  82:	7be000ef          	jal	840 <printf>
  86:	4911                	li	s2,4

    // ---- codigo do pai: registra o tick de CRIACAO logo apos o fork() ----
    // Esse eh o instante em que o xv6 marca o filho como RUNNABLE,
    // ou seja, quando ele "chega" na fila de prontos.
    int criacao = uptime();
    printf("[PID %d] CRIACAO (chegada) em tick %d\n", child_pid, criacao);
  88:	00001997          	auipc	s3,0x1
  8c:	a7898993          	addi	s3,s3,-1416 # b00 <malloc+0x208>
    int child_pid = fork();
  90:	34a000ef          	jal	3da <fork>
  94:	84aa                	mv	s1,a0
    if (child_pid < 0) {
  96:	02054c63          	bltz	a0,ce <main+0xa0>
    if (child_pid == 0) {
  9a:	c139                	beqz	a0,e0 <main+0xb2>
    int criacao = uptime();
  9c:	3de000ef          	jal	47a <uptime>
  a0:	862a                	mv	a2,a0
    printf("[PID %d] CRIACAO (chegada) em tick %d\n", child_pid, criacao);
  a2:	85a6                	mv	a1,s1
  a4:	854e                	mv	a0,s3
  a6:	79a000ef          	jal	840 <printf>
  for (i = 0; i < NUM_FILHOS; i++) {
  aa:	397d                	addiw	s2,s2,-1
  ac:	fe0912e3          	bnez	s2,90 <main+0x62>
  b0:	4491                	li	s1,4
  }

  // pai espera todos os filhos
  for (i = 0; i < NUM_FILHOS; i++) {
    wait(0);
  b2:	4501                	li	a0,0
  b4:	336000ef          	jal	3ea <wait>
  for (i = 0; i < NUM_FILHOS; i++) {
  b8:	34fd                	addiw	s1,s1,-1
  ba:	fce5                	bnez	s1,b2 <main+0x84>
  }

  printf("\nTodos os filhos terminaram.\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	a6c50513          	addi	a0,a0,-1428 # b28 <malloc+0x230>
  c4:	77c000ef          	jal	840 <printf>
  exit(0);
  c8:	4501                	li	a0,0
  ca:	318000ef          	jal	3e2 <exit>
      printf("erro no fork\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	9ca50513          	addi	a0,a0,-1590 # a98 <malloc+0x1a0>
  d6:	76a000ef          	jal	840 <printf>
      exit(1);
  da:	4505                	li	a0,1
  dc:	306000ef          	jal	3e2 <exit>
      int meu_pid = getpid();
  e0:	382000ef          	jal	462 <getpid>
  e4:	84aa                	mv	s1,a0
      int inicio = uptime();
  e6:	394000ef          	jal	47a <uptime>
  ea:	892a                	mv	s2,a0
      printf("[PID %d] INICIO em tick %d (pai=%d)\n",
  ec:	3a6000ef          	jal	492 <getppid>
  f0:	86aa                	mv	a3,a0
  f2:	864a                	mv	a2,s2
  f4:	85a6                	mv	a1,s1
  f6:	00001517          	auipc	a0,0x1
  fa:	9b250513          	addi	a0,a0,-1614 # aa8 <malloc+0x1b0>
  fe:	742000ef          	jal	840 <printf>
      busy_loop(ITERACOES);
 102:	0bebc537          	lui	a0,0xbebc
 106:	20050513          	addi	a0,a0,512 # bebc200 <base+0xbebb1f0>
 10a:	ef7ff0ef          	jal	0 <busy_loop>
      int fim = uptime();
 10e:	36c000ef          	jal	47a <uptime>
 112:	862a                	mv	a2,a0
      printf("[PID %d] FIM em tick %d (duracao: %d ticks)\n",
 114:	412506bb          	subw	a3,a0,s2
 118:	85a6                	mv	a1,s1
 11a:	00001517          	auipc	a0,0x1
 11e:	9b650513          	addi	a0,a0,-1610 # ad0 <malloc+0x1d8>
 122:	71e000ef          	jal	840 <printf>
      exit(0);
 126:	4501                	li	a0,0
 128:	2ba000ef          	jal	3e2 <exit>

000000000000012c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e406                	sd	ra,8(sp)
 130:	e022                	sd	s0,0(sp)
 132:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 134:	efbff0ef          	jal	2e <main>
  exit(r);
 138:	2aa000ef          	jal	3e2 <exit>

000000000000013c <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e406                	sd	ra,8(sp)
 140:	e022                	sd	s0,0(sp)
 142:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 144:	87aa                	mv	a5,a0
 146:	0585                	addi	a1,a1,1
 148:	0785                	addi	a5,a5,1
 14a:	fff5c703          	lbu	a4,-1(a1)
 14e:	fee78fa3          	sb	a4,-1(a5)
 152:	fb75                	bnez	a4,146 <strcpy+0xa>
    ;
  return os;
}
 154:	60a2                	ld	ra,8(sp)
 156:	6402                	ld	s0,0(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret

000000000000015c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 164:	00054783          	lbu	a5,0(a0)
 168:	cb91                	beqz	a5,17c <strcmp+0x20>
 16a:	0005c703          	lbu	a4,0(a1)
 16e:	00f71763          	bne	a4,a5,17c <strcmp+0x20>
    p++, q++;
 172:	0505                	addi	a0,a0,1
 174:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 176:	00054783          	lbu	a5,0(a0)
 17a:	fbe5                	bnez	a5,16a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 17c:	0005c503          	lbu	a0,0(a1)
}
 180:	40a7853b          	subw	a0,a5,a0
 184:	60a2                	ld	ra,8(sp)
 186:	6402                	ld	s0,0(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret

000000000000018c <strlen>:

uint
strlen(const char *s)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e406                	sd	ra,8(sp)
 190:	e022                	sd	s0,0(sp)
 192:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 194:	00054783          	lbu	a5,0(a0)
 198:	cf91                	beqz	a5,1b4 <strlen+0x28>
 19a:	00150793          	addi	a5,a0,1
 19e:	86be                	mv	a3,a5
 1a0:	0785                	addi	a5,a5,1
 1a2:	fff7c703          	lbu	a4,-1(a5)
 1a6:	ff65                	bnez	a4,19e <strlen+0x12>
 1a8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1ac:	60a2                	ld	ra,8(sp)
 1ae:	6402                	ld	s0,0(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret
  for (n = 0; s[n]; n++)
 1b4:	4501                	li	a0,0
 1b6:	bfdd                	j	1ac <strlen+0x20>

00000000000001b8 <memset>:

void *
memset(void *dst, int c, uint n)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e406                	sd	ra,8(sp)
 1bc:	e022                	sd	s0,0(sp)
 1be:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 1c0:	ca19                	beqz	a2,1d6 <memset+0x1e>
 1c2:	87aa                	mv	a5,a0
 1c4:	1602                	slli	a2,a2,0x20
 1c6:	9201                	srli	a2,a2,0x20
 1c8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1cc:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 1d0:	0785                	addi	a5,a5,1
 1d2:	fee79de3          	bne	a5,a4,1cc <memset+0x14>
  }
  return dst;
}
 1d6:	60a2                	ld	ra,8(sp)
 1d8:	6402                	ld	s0,0(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret

00000000000001de <strchr>:

char *
strchr(const char *s, char c)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e406                	sd	ra,8(sp)
 1e2:	e022                	sd	s0,0(sp)
 1e4:	0800                	addi	s0,sp,16
  for (; *s; s++)
 1e6:	00054783          	lbu	a5,0(a0)
 1ea:	cf81                	beqz	a5,202 <strchr+0x24>
    if (*s == c)
 1ec:	00f58763          	beq	a1,a5,1fa <strchr+0x1c>
  for (; *s; s++)
 1f0:	0505                	addi	a0,a0,1
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	fbfd                	bnez	a5,1ec <strchr+0xe>
      return (char *)s;
  return 0;
 1f8:	4501                	li	a0,0
}
 1fa:	60a2                	ld	ra,8(sp)
 1fc:	6402                	ld	s0,0(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
  return 0;
 202:	4501                	li	a0,0
 204:	bfdd                	j	1fa <strchr+0x1c>

0000000000000206 <gets>:

char *
gets(char *buf, int max)
{
 206:	711d                	addi	sp,sp,-96
 208:	ec86                	sd	ra,88(sp)
 20a:	e8a2                	sd	s0,80(sp)
 20c:	e4a6                	sd	s1,72(sp)
 20e:	e0ca                	sd	s2,64(sp)
 210:	fc4e                	sd	s3,56(sp)
 212:	f852                	sd	s4,48(sp)
 214:	f456                	sd	s5,40(sp)
 216:	f05a                	sd	s6,32(sp)
 218:	ec5e                	sd	s7,24(sp)
 21a:	e862                	sd	s8,16(sp)
 21c:	1080                	addi	s0,sp,96
 21e:	8baa                	mv	s7,a0
 220:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 222:	892a                	mv	s2,a0
 224:	4481                	li	s1,0
    cc = read(0, &c, 1);
 226:	faf40b13          	addi	s6,s0,-81
 22a:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 22c:	8c26                	mv	s8,s1
 22e:	0014899b          	addiw	s3,s1,1
 232:	84ce                	mv	s1,s3
 234:	0349d463          	bge	s3,s4,25c <gets+0x56>
    cc = read(0, &c, 1);
 238:	8656                	mv	a2,s5
 23a:	85da                	mv	a1,s6
 23c:	4501                	li	a0,0
 23e:	1bc000ef          	jal	3fa <read>
    if (cc < 1)
 242:	00a05d63          	blez	a0,25c <gets+0x56>
      break;
    buf[i++] = c;
 246:	faf44783          	lbu	a5,-81(s0)
 24a:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 24e:	0905                	addi	s2,s2,1
 250:	ff678713          	addi	a4,a5,-10
 254:	c319                	beqz	a4,25a <gets+0x54>
 256:	17cd                	addi	a5,a5,-13
 258:	fbf1                	bnez	a5,22c <gets+0x26>
    buf[i++] = c;
 25a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 25c:	9c5e                	add	s8,s8,s7
 25e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 262:	855e                	mv	a0,s7
 264:	60e6                	ld	ra,88(sp)
 266:	6446                	ld	s0,80(sp)
 268:	64a6                	ld	s1,72(sp)
 26a:	6906                	ld	s2,64(sp)
 26c:	79e2                	ld	s3,56(sp)
 26e:	7a42                	ld	s4,48(sp)
 270:	7aa2                	ld	s5,40(sp)
 272:	7b02                	ld	s6,32(sp)
 274:	6be2                	ld	s7,24(sp)
 276:	6c42                	ld	s8,16(sp)
 278:	6125                	addi	sp,sp,96
 27a:	8082                	ret

000000000000027c <stat>:

int
stat(const char *n, struct stat *st)
{
 27c:	1101                	addi	sp,sp,-32
 27e:	ec06                	sd	ra,24(sp)
 280:	e822                	sd	s0,16(sp)
 282:	e04a                	sd	s2,0(sp)
 284:	1000                	addi	s0,sp,32
 286:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 288:	4581                	li	a1,0
 28a:	198000ef          	jal	422 <open>
  if (fd < 0)
 28e:	02054263          	bltz	a0,2b2 <stat+0x36>
 292:	e426                	sd	s1,8(sp)
 294:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 296:	85ca                	mv	a1,s2
 298:	1a2000ef          	jal	43a <fstat>
 29c:	892a                	mv	s2,a0
  close(fd);
 29e:	8526                	mv	a0,s1
 2a0:	16a000ef          	jal	40a <close>
  return r;
 2a4:	64a2                	ld	s1,8(sp)
}
 2a6:	854a                	mv	a0,s2
 2a8:	60e2                	ld	ra,24(sp)
 2aa:	6442                	ld	s0,16(sp)
 2ac:	6902                	ld	s2,0(sp)
 2ae:	6105                	addi	sp,sp,32
 2b0:	8082                	ret
    return -1;
 2b2:	57fd                	li	a5,-1
 2b4:	893e                	mv	s2,a5
 2b6:	bfc5                	j	2a6 <stat+0x2a>

00000000000002b8 <atoi>:

int
atoi(const char *s)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 2c0:	00054683          	lbu	a3,0(a0)
 2c4:	fd06879b          	addiw	a5,a3,-48
 2c8:	0ff7f793          	zext.b	a5,a5
 2cc:	4625                	li	a2,9
 2ce:	02f66963          	bltu	a2,a5,300 <atoi+0x48>
 2d2:	872a                	mv	a4,a0
  n = 0;
 2d4:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 2d6:	0705                	addi	a4,a4,1
 2d8:	0025179b          	slliw	a5,a0,0x2
 2dc:	9fa9                	addw	a5,a5,a0
 2de:	0017979b          	slliw	a5,a5,0x1
 2e2:	9fb5                	addw	a5,a5,a3
 2e4:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 2e8:	00074683          	lbu	a3,0(a4)
 2ec:	fd06879b          	addiw	a5,a3,-48
 2f0:	0ff7f793          	zext.b	a5,a5
 2f4:	fef671e3          	bgeu	a2,a5,2d6 <atoi+0x1e>
  return n;
}
 2f8:	60a2                	ld	ra,8(sp)
 2fa:	6402                	ld	s0,0(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
  n = 0;
 300:	4501                	li	a0,0
 302:	bfdd                	j	2f8 <atoi+0x40>

0000000000000304 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 304:	1141                	addi	sp,sp,-16
 306:	e406                	sd	ra,8(sp)
 308:	e022                	sd	s0,0(sp)
 30a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30c:	02b57563          	bgeu	a0,a1,336 <memmove+0x32>
    while (n-- > 0)
 310:	00c05f63          	blez	a2,32e <memmove+0x2a>
 314:	1602                	slli	a2,a2,0x20
 316:	9201                	srli	a2,a2,0x20
 318:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31c:	872a                	mv	a4,a0
      *dst++ = *src++;
 31e:	0585                	addi	a1,a1,1
 320:	0705                	addi	a4,a4,1
 322:	fff5c683          	lbu	a3,-1(a1)
 326:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 32a:	fee79ae3          	bne	a5,a4,31e <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 32e:	60a2                	ld	ra,8(sp)
 330:	6402                	ld	s0,0(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret
    while (n-- > 0)
 336:	fec05ce3          	blez	a2,32e <memmove+0x2a>
    dst += n;
 33a:	00c50733          	add	a4,a0,a2
    src += n;
 33e:	95b2                	add	a1,a1,a2
 340:	fff6079b          	addiw	a5,a2,-1
 344:	1782                	slli	a5,a5,0x20
 346:	9381                	srli	a5,a5,0x20
 348:	fff7c793          	not	a5,a5
 34c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 34e:	15fd                	addi	a1,a1,-1
 350:	177d                	addi	a4,a4,-1
 352:	0005c683          	lbu	a3,0(a1)
 356:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 35a:	fef71ae3          	bne	a4,a5,34e <memmove+0x4a>
 35e:	bfc1                	j	32e <memmove+0x2a>

0000000000000360 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 360:	1141                	addi	sp,sp,-16
 362:	e406                	sd	ra,8(sp)
 364:	e022                	sd	s0,0(sp)
 366:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 368:	c61d                	beqz	a2,396 <memcmp+0x36>
 36a:	1602                	slli	a2,a2,0x20
 36c:	9201                	srli	a2,a2,0x20
 36e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 372:	00054783          	lbu	a5,0(a0)
 376:	0005c703          	lbu	a4,0(a1)
 37a:	00e79863          	bne	a5,a4,38a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 37e:	0505                	addi	a0,a0,1
    p2++;
 380:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 382:	fed518e3          	bne	a0,a3,372 <memcmp+0x12>
  }
  return 0;
 386:	4501                	li	a0,0
 388:	a019                	j	38e <memcmp+0x2e>
      return *p1 - *p2;
 38a:	40e7853b          	subw	a0,a5,a4
}
 38e:	60a2                	ld	ra,8(sp)
 390:	6402                	ld	s0,0(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret
  return 0;
 396:	4501                	li	a0,0
 398:	bfdd                	j	38e <memcmp+0x2e>

000000000000039a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e406                	sd	ra,8(sp)
 39e:	e022                	sd	s0,0(sp)
 3a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a2:	f63ff0ef          	jal	304 <memmove>
}
 3a6:	60a2                	ld	ra,8(sp)
 3a8:	6402                	ld	s0,0(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret

00000000000003ae <sbrk>:

char *
sbrk(int n)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3b6:	4585                	li	a1,1
 3b8:	0b2000ef          	jal	46a <sys_sbrk>
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret

00000000000003c4 <sbrklazy>:

char *
sbrklazy(int n)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e406                	sd	ra,8(sp)
 3c8:	e022                	sd	s0,0(sp)
 3ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3cc:	4589                	li	a1,2
 3ce:	09c000ef          	jal	46a <sys_sbrk>
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3da:	4885                	li	a7,1
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e2:	4889                	li	a7,2
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ea:	488d                	li	a7,3
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f2:	4891                	li	a7,4
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <read>:
.global read
read:
 li a7, SYS_read
 3fa:	4895                	li	a7,5
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <write>:
.global write
write:
 li a7, SYS_write
 402:	48c1                	li	a7,16
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <close>:
.global close
close:
 li a7, SYS_close
 40a:	48d5                	li	a7,21
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <kill>:
.global kill
kill:
 li a7, SYS_kill
 412:	4899                	li	a7,6
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <exec>:
.global exec
exec:
 li a7, SYS_exec
 41a:	489d                	li	a7,7
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <open>:
.global open
open:
 li a7, SYS_open
 422:	48bd                	li	a7,15
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 42a:	48c5                	li	a7,17
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 432:	48c9                	li	a7,18
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 43a:	48a1                	li	a7,8
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <link>:
.global link
link:
 li a7, SYS_link
 442:	48cd                	li	a7,19
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 44a:	48d1                	li	a7,20
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 452:	48a5                	li	a7,9
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <dup>:
.global dup
dup:
 li a7, SYS_dup
 45a:	48a9                	li	a7,10
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 462:	48ad                	li	a7,11
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 46a:	48b1                	li	a7,12
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <pause>:
.global pause
pause:
 li a7, SYS_pause
 472:	48b5                	li	a7,13
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 47a:	48b9                	li	a7,14
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <sync>:
.global sync
sync:
 li a7, SYS_sync
 482:	48d9                	li	a7,22
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <getidade>:
.global getidade
getidade:
 li a7, SYS_getidade
 48a:	48dd                	li	a7,23
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 492:	48e1                	li	a7,24
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 49a:	1101                	addi	sp,sp,-32
 49c:	ec06                	sd	ra,24(sp)
 49e:	e822                	sd	s0,16(sp)
 4a0:	1000                	addi	s0,sp,32
 4a2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a6:	4605                	li	a2,1
 4a8:	fef40593          	addi	a1,s0,-17
 4ac:	f57ff0ef          	jal	402 <write>
}
 4b0:	60e2                	ld	ra,24(sp)
 4b2:	6442                	ld	s0,16(sp)
 4b4:	6105                	addi	sp,sp,32
 4b6:	8082                	ret

00000000000004b8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4b8:	715d                	addi	sp,sp,-80
 4ba:	e486                	sd	ra,72(sp)
 4bc:	e0a2                	sd	s0,64(sp)
 4be:	f84a                	sd	s2,48(sp)
 4c0:	f44e                	sd	s3,40(sp)
 4c2:	0880                	addi	s0,sp,80
 4c4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 4c6:	c6d1                	beqz	a3,552 <printint+0x9a>
 4c8:	0805d563          	bgez	a1,552 <printint+0x9a>
    neg = 1;
    x = -xx;
 4cc:	40b005b3          	neg	a1,a1
    neg = 1;
 4d0:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4d2:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4d6:	86ce                	mv	a3,s3
  i = 0;
 4d8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 4da:	00000817          	auipc	a6,0x0
 4de:	67680813          	addi	a6,a6,1654 # b50 <digits>
 4e2:	88ba                	mv	a7,a4
 4e4:	0017051b          	addiw	a0,a4,1
 4e8:	872a                	mv	a4,a0
 4ea:	02c5f7b3          	remu	a5,a1,a2
 4ee:	97c2                	add	a5,a5,a6
 4f0:	0007c783          	lbu	a5,0(a5)
 4f4:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 4f8:	87ae                	mv	a5,a1
 4fa:	02c5d5b3          	divu	a1,a1,a2
 4fe:	0685                	addi	a3,a3,1
 500:	fec7f1e3          	bgeu	a5,a2,4e2 <printint+0x2a>
  if (neg)
 504:	00030c63          	beqz	t1,51c <printint+0x64>
    buf[i++] = '-';
 508:	fd050793          	addi	a5,a0,-48
 50c:	00878533          	add	a0,a5,s0
 510:	02d00793          	li	a5,45
 514:	fef50423          	sb	a5,-24(a0)
 518:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 51c:	02e05563          	blez	a4,546 <printint+0x8e>
 520:	fc26                	sd	s1,56(sp)
 522:	377d                	addiw	a4,a4,-1
 524:	00e984b3          	add	s1,s3,a4
 528:	19fd                	addi	s3,s3,-1
 52a:	99ba                	add	s3,s3,a4
 52c:	1702                	slli	a4,a4,0x20
 52e:	9301                	srli	a4,a4,0x20
 530:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 534:	0004c583          	lbu	a1,0(s1)
 538:	854a                	mv	a0,s2
 53a:	f61ff0ef          	jal	49a <putc>
  while (--i >= 0)
 53e:	14fd                	addi	s1,s1,-1
 540:	ff349ae3          	bne	s1,s3,534 <printint+0x7c>
 544:	74e2                	ld	s1,56(sp)
}
 546:	60a6                	ld	ra,72(sp)
 548:	6406                	ld	s0,64(sp)
 54a:	7942                	ld	s2,48(sp)
 54c:	79a2                	ld	s3,40(sp)
 54e:	6161                	addi	sp,sp,80
 550:	8082                	ret
  neg = 0;
 552:	4301                	li	t1,0
 554:	bfbd                	j	4d2 <printint+0x1a>

0000000000000556 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 556:	711d                	addi	sp,sp,-96
 558:	ec86                	sd	ra,88(sp)
 55a:	e8a2                	sd	s0,80(sp)
 55c:	e4a6                	sd	s1,72(sp)
 55e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 560:	0005c483          	lbu	s1,0(a1)
 564:	22048363          	beqz	s1,78a <vprintf+0x234>
 568:	e0ca                	sd	s2,64(sp)
 56a:	fc4e                	sd	s3,56(sp)
 56c:	f852                	sd	s4,48(sp)
 56e:	f456                	sd	s5,40(sp)
 570:	f05a                	sd	s6,32(sp)
 572:	ec5e                	sd	s7,24(sp)
 574:	e862                	sd	s8,16(sp)
 576:	8b2a                	mv	s6,a0
 578:	8a2e                	mv	s4,a1
 57a:	8bb2                	mv	s7,a2
  state = 0;
 57c:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 57e:	4901                	li	s2,0
 580:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 582:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 586:	06400c13          	li	s8,100
 58a:	a00d                	j	5ac <vprintf+0x56>
        putc(fd, c0);
 58c:	85a6                	mv	a1,s1
 58e:	855a                	mv	a0,s6
 590:	f0bff0ef          	jal	49a <putc>
 594:	a019                	j	59a <vprintf+0x44>
    } else if (state == '%') {
 596:	03598363          	beq	s3,s5,5bc <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 59a:	0019079b          	addiw	a5,s2,1
 59e:	893e                	mv	s2,a5
 5a0:	873e                	mv	a4,a5
 5a2:	97d2                	add	a5,a5,s4
 5a4:	0007c483          	lbu	s1,0(a5)
 5a8:	1c048a63          	beqz	s1,77c <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5ac:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 5b0:	fe0993e3          	bnez	s3,596 <vprintf+0x40>
      if (c0 == '%') {
 5b4:	fd579ce3          	bne	a5,s5,58c <vprintf+0x36>
        state = '%';
 5b8:	89be                	mv	s3,a5
 5ba:	b7c5                	j	59a <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 5bc:	00ea06b3          	add	a3,s4,a4
 5c0:	0016c603          	lbu	a2,1(a3)
      if (c1)
 5c4:	1c060863          	beqz	a2,794 <vprintf+0x23e>
      if (c0 == 'd') {
 5c8:	03878763          	beq	a5,s8,5f6 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 5cc:	f9478693          	addi	a3,a5,-108
 5d0:	0016b693          	seqz	a3,a3
 5d4:	f9c60593          	addi	a1,a2,-100
 5d8:	e99d                	bnez	a1,60e <vprintf+0xb8>
 5da:	ca95                	beqz	a3,60e <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5dc:	008b8493          	addi	s1,s7,8
 5e0:	4685                	li	a3,1
 5e2:	4629                	li	a2,10
 5e4:	000bb583          	ld	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	ecfff0ef          	jal	4b8 <printint>
        i += 1;
 5ee:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f0:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b75d                	j	59a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5f6:	008b8493          	addi	s1,s7,8
 5fa:	4685                	li	a3,1
 5fc:	4629                	li	a2,10
 5fe:	000ba583          	lw	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	eb5ff0ef          	jal	4b8 <printint>
 608:	8ba6                	mv	s7,s1
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b779                	j	59a <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 60e:	9752                	add	a4,a4,s4
 610:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 614:	f9460713          	addi	a4,a2,-108
 618:	00173713          	seqz	a4,a4
 61c:	8f75                	and	a4,a4,a3
 61e:	f9c58513          	addi	a0,a1,-100
 622:	18051363          	bnez	a0,7a8 <vprintf+0x252>
 626:	18070163          	beqz	a4,7a8 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62a:	008b8493          	addi	s1,s7,8
 62e:	4685                	li	a3,1
 630:	4629                	li	a2,10
 632:	000bb583          	ld	a1,0(s7)
 636:	855a                	mv	a0,s6
 638:	e81ff0ef          	jal	4b8 <printint>
        i += 2;
 63c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 63e:	8ba6                	mv	s7,s1
      state = 0;
 640:	4981                	li	s3,0
        i += 2;
 642:	bfa1                	j	59a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 644:	008b8493          	addi	s1,s7,8
 648:	4681                	li	a3,0
 64a:	4629                	li	a2,10
 64c:	000be583          	lwu	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	e67ff0ef          	jal	4b8 <printint>
 656:	8ba6                	mv	s7,s1
      state = 0;
 658:	4981                	li	s3,0
 65a:	b781                	j	59a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65c:	008b8493          	addi	s1,s7,8
 660:	4681                	li	a3,0
 662:	4629                	li	a2,10
 664:	000bb583          	ld	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	e4fff0ef          	jal	4b8 <printint>
        i += 1;
 66e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 670:	8ba6                	mv	s7,s1
      state = 0;
 672:	4981                	li	s3,0
 674:	b71d                	j	59a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 676:	008b8493          	addi	s1,s7,8
 67a:	4681                	li	a3,0
 67c:	4629                	li	a2,10
 67e:	000bb583          	ld	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	e35ff0ef          	jal	4b8 <printint>
        i += 2;
 688:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 68a:	8ba6                	mv	s7,s1
      state = 0;
 68c:	4981                	li	s3,0
        i += 2;
 68e:	b731                	j	59a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 690:	008b8493          	addi	s1,s7,8
 694:	4681                	li	a3,0
 696:	4641                	li	a2,16
 698:	000be583          	lwu	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	e1bff0ef          	jal	4b8 <printint>
 6a2:	8ba6                	mv	s7,s1
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bdd5                	j	59a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a8:	008b8493          	addi	s1,s7,8
 6ac:	4681                	li	a3,0
 6ae:	4641                	li	a2,16
 6b0:	000bb583          	ld	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	e03ff0ef          	jal	4b8 <printint>
        i += 1;
 6ba:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6bc:	8ba6                	mv	s7,s1
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bde9                	j	59a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c2:	008b8493          	addi	s1,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000bb583          	ld	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	de9ff0ef          	jal	4b8 <printint>
        i += 2;
 6d4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d6:	8ba6                	mv	s7,s1
      state = 0;
 6d8:	4981                	li	s3,0
        i += 2;
 6da:	b5c1                	j	59a <vprintf+0x44>
 6dc:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6de:	008b8793          	addi	a5,s7,8
 6e2:	8cbe                	mv	s9,a5
 6e4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e8:	03000593          	li	a1,48
 6ec:	855a                	mv	a0,s6
 6ee:	dadff0ef          	jal	49a <putc>
  putc(fd, 'x');
 6f2:	07800593          	li	a1,120
 6f6:	855a                	mv	a0,s6
 6f8:	da3ff0ef          	jal	49a <putc>
 6fc:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fe:	00000b97          	auipc	s7,0x0
 702:	452b8b93          	addi	s7,s7,1106 # b50 <digits>
 706:	03c9d793          	srli	a5,s3,0x3c
 70a:	97de                	add	a5,a5,s7
 70c:	0007c583          	lbu	a1,0(a5)
 710:	855a                	mv	a0,s6
 712:	d89ff0ef          	jal	49a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 716:	0992                	slli	s3,s3,0x4
 718:	34fd                	addiw	s1,s1,-1
 71a:	f4f5                	bnez	s1,706 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 71c:	8be6                	mv	s7,s9
      state = 0;
 71e:	4981                	li	s3,0
 720:	6ca2                	ld	s9,8(sp)
 722:	bda5                	j	59a <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 724:	008b8493          	addi	s1,s7,8
 728:	000bc583          	lbu	a1,0(s7)
 72c:	855a                	mv	a0,s6
 72e:	d6dff0ef          	jal	49a <putc>
 732:	8ba6                	mv	s7,s1
      state = 0;
 734:	4981                	li	s3,0
 736:	b595                	j	59a <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 738:	008b8993          	addi	s3,s7,8
 73c:	000bb483          	ld	s1,0(s7)
 740:	cc91                	beqz	s1,75c <vprintf+0x206>
        for (; *s; s++)
 742:	0004c583          	lbu	a1,0(s1)
 746:	c985                	beqz	a1,776 <vprintf+0x220>
          putc(fd, *s);
 748:	855a                	mv	a0,s6
 74a:	d51ff0ef          	jal	49a <putc>
        for (; *s; s++)
 74e:	0485                	addi	s1,s1,1
 750:	0004c583          	lbu	a1,0(s1)
 754:	f9f5                	bnez	a1,748 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 756:	8bce                	mv	s7,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	b581                	j	59a <vprintf+0x44>
          s = "(null)";
 75c:	00000497          	auipc	s1,0x0
 760:	3ec48493          	addi	s1,s1,1004 # b48 <malloc+0x250>
        for (; *s; s++)
 764:	02800593          	li	a1,40
 768:	b7c5                	j	748 <vprintf+0x1f2>
        putc(fd, '%');
 76a:	85be                	mv	a1,a5
 76c:	855a                	mv	a0,s6
 76e:	d2dff0ef          	jal	49a <putc>
      state = 0;
 772:	4981                	li	s3,0
 774:	b51d                	j	59a <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 776:	8bce                	mv	s7,s3
      state = 0;
 778:	4981                	li	s3,0
 77a:	b505                	j	59a <vprintf+0x44>
 77c:	6906                	ld	s2,64(sp)
 77e:	79e2                	ld	s3,56(sp)
 780:	7a42                	ld	s4,48(sp)
 782:	7aa2                	ld	s5,40(sp)
 784:	7b02                	ld	s6,32(sp)
 786:	6be2                	ld	s7,24(sp)
 788:	6c42                	ld	s8,16(sp)
    }
  }
}
 78a:	60e6                	ld	ra,88(sp)
 78c:	6446                	ld	s0,80(sp)
 78e:	64a6                	ld	s1,72(sp)
 790:	6125                	addi	sp,sp,96
 792:	8082                	ret
      if (c0 == 'd') {
 794:	06400713          	li	a4,100
 798:	e4e78fe3          	beq	a5,a4,5f6 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 79c:	f9478693          	addi	a3,a5,-108
 7a0:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7a4:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 7a6:	4701                	li	a4,0
      } else if (c0 == 'u') {
 7a8:	07500513          	li	a0,117
 7ac:	e8a78ce3          	beq	a5,a0,644 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 7b0:	f8b60513          	addi	a0,a2,-117
 7b4:	e119                	bnez	a0,7ba <vprintf+0x264>
 7b6:	ea0693e3          	bnez	a3,65c <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 7ba:	f8b58513          	addi	a0,a1,-117
 7be:	e119                	bnez	a0,7c4 <vprintf+0x26e>
 7c0:	ea071be3          	bnez	a4,676 <vprintf+0x120>
      } else if (c0 == 'x') {
 7c4:	07800513          	li	a0,120
 7c8:	eca784e3          	beq	a5,a0,690 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 7cc:	f8860613          	addi	a2,a2,-120
 7d0:	e219                	bnez	a2,7d6 <vprintf+0x280>
 7d2:	ec069be3          	bnez	a3,6a8 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 7d6:	f8858593          	addi	a1,a1,-120
 7da:	e199                	bnez	a1,7e0 <vprintf+0x28a>
 7dc:	ee0713e3          	bnez	a4,6c2 <vprintf+0x16c>
      } else if (c0 == 'p') {
 7e0:	07000713          	li	a4,112
 7e4:	eee78ce3          	beq	a5,a4,6dc <vprintf+0x186>
      } else if (c0 == 'c') {
 7e8:	06300713          	li	a4,99
 7ec:	f2e78ce3          	beq	a5,a4,724 <vprintf+0x1ce>
      } else if (c0 == 's') {
 7f0:	07300713          	li	a4,115
 7f4:	f4e782e3          	beq	a5,a4,738 <vprintf+0x1e2>
      } else if (c0 == '%') {
 7f8:	02500713          	li	a4,37
 7fc:	f6e787e3          	beq	a5,a4,76a <vprintf+0x214>
        putc(fd, '%');
 800:	02500593          	li	a1,37
 804:	855a                	mv	a0,s6
 806:	c95ff0ef          	jal	49a <putc>
        putc(fd, c0);
 80a:	85a6                	mv	a1,s1
 80c:	855a                	mv	a0,s6
 80e:	c8dff0ef          	jal	49a <putc>
      state = 0;
 812:	4981                	li	s3,0
 814:	b359                	j	59a <vprintf+0x44>

0000000000000816 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 816:	715d                	addi	sp,sp,-80
 818:	ec06                	sd	ra,24(sp)
 81a:	e822                	sd	s0,16(sp)
 81c:	1000                	addi	s0,sp,32
 81e:	e010                	sd	a2,0(s0)
 820:	e414                	sd	a3,8(s0)
 822:	e818                	sd	a4,16(s0)
 824:	ec1c                	sd	a5,24(s0)
 826:	03043023          	sd	a6,32(s0)
 82a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 82e:	8622                	mv	a2,s0
 830:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 834:	d23ff0ef          	jal	556 <vprintf>
}
 838:	60e2                	ld	ra,24(sp)
 83a:	6442                	ld	s0,16(sp)
 83c:	6161                	addi	sp,sp,80
 83e:	8082                	ret

0000000000000840 <printf>:

void
printf(const char *fmt, ...)
{
 840:	711d                	addi	sp,sp,-96
 842:	ec06                	sd	ra,24(sp)
 844:	e822                	sd	s0,16(sp)
 846:	1000                	addi	s0,sp,32
 848:	e40c                	sd	a1,8(s0)
 84a:	e810                	sd	a2,16(s0)
 84c:	ec14                	sd	a3,24(s0)
 84e:	f018                	sd	a4,32(s0)
 850:	f41c                	sd	a5,40(s0)
 852:	03043823          	sd	a6,48(s0)
 856:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 85a:	00840613          	addi	a2,s0,8
 85e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 862:	85aa                	mv	a1,a0
 864:	4505                	li	a0,1
 866:	cf1ff0ef          	jal	556 <vprintf>
}
 86a:	60e2                	ld	ra,24(sp)
 86c:	6442                	ld	s0,16(sp)
 86e:	6125                	addi	sp,sp,96
 870:	8082                	ret

0000000000000872 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 872:	1141                	addi	sp,sp,-16
 874:	e406                	sd	ra,8(sp)
 876:	e022                	sd	s0,0(sp)
 878:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 87a:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87e:	00000797          	auipc	a5,0x0
 882:	7827b783          	ld	a5,1922(a5) # 1000 <freep>
 886:	a039                	j	894 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 888:	6398                	ld	a4,0(a5)
 88a:	00e7e463          	bltu	a5,a4,892 <free+0x20>
 88e:	00e6ea63          	bltu	a3,a4,8a2 <free+0x30>
{
 892:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 894:	fed7fae3          	bgeu	a5,a3,888 <free+0x16>
 898:	6398                	ld	a4,0(a5)
 89a:	00e6e463          	bltu	a3,a4,8a2 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89e:	fee7eae3          	bltu	a5,a4,892 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 8a2:	ff852583          	lw	a1,-8(a0)
 8a6:	6390                	ld	a2,0(a5)
 8a8:	02059813          	slli	a6,a1,0x20
 8ac:	01c85713          	srli	a4,a6,0x1c
 8b0:	9736                	add	a4,a4,a3
 8b2:	02e60563          	beq	a2,a4,8dc <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8b6:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 8ba:	4790                	lw	a2,8(a5)
 8bc:	02061593          	slli	a1,a2,0x20
 8c0:	01c5d713          	srli	a4,a1,0x1c
 8c4:	973e                	add	a4,a4,a5
 8c6:	02e68263          	beq	a3,a4,8ea <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8ca:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8cc:	00000717          	auipc	a4,0x0
 8d0:	72f73a23          	sd	a5,1844(a4) # 1000 <freep>
}
 8d4:	60a2                	ld	ra,8(sp)
 8d6:	6402                	ld	s0,0(sp)
 8d8:	0141                	addi	sp,sp,16
 8da:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8dc:	4618                	lw	a4,8(a2)
 8de:	9f2d                	addw	a4,a4,a1
 8e0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e4:	6398                	ld	a4,0(a5)
 8e6:	6310                	ld	a2,0(a4)
 8e8:	b7f9                	j	8b6 <free+0x44>
    p->s.size += bp->s.size;
 8ea:	ff852703          	lw	a4,-8(a0)
 8ee:	9f31                	addw	a4,a4,a2
 8f0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8f2:	ff053683          	ld	a3,-16(a0)
 8f6:	bfd1                	j	8ca <free+0x58>

00000000000008f8 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 8f8:	7139                	addi	sp,sp,-64
 8fa:	fc06                	sd	ra,56(sp)
 8fc:	f822                	sd	s0,48(sp)
 8fe:	f04a                	sd	s2,32(sp)
 900:	ec4e                	sd	s3,24(sp)
 902:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 904:	02051993          	slli	s3,a0,0x20
 908:	0209d993          	srli	s3,s3,0x20
 90c:	09bd                	addi	s3,s3,15
 90e:	0049d993          	srli	s3,s3,0x4
 912:	2985                	addiw	s3,s3,1
 914:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 916:	00000517          	auipc	a0,0x0
 91a:	6ea53503          	ld	a0,1770(a0) # 1000 <freep>
 91e:	c905                	beqz	a0,94e <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 920:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 922:	4798                	lw	a4,8(a5)
 924:	09377663          	bgeu	a4,s3,9b0 <malloc+0xb8>
 928:	f426                	sd	s1,40(sp)
 92a:	e852                	sd	s4,16(sp)
 92c:	e456                	sd	s5,8(sp)
 92e:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 930:	8a4e                	mv	s4,s3
 932:	6705                	lui	a4,0x1
 934:	00e9f363          	bgeu	s3,a4,93a <malloc+0x42>
 938:	6a05                	lui	s4,0x1
 93a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 93e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 942:	00000497          	auipc	s1,0x0
 946:	6be48493          	addi	s1,s1,1726 # 1000 <freep>
  if (p == SBRK_ERROR)
 94a:	5afd                	li	s5,-1
 94c:	a83d                	j	98a <malloc+0x92>
 94e:	f426                	sd	s1,40(sp)
 950:	e852                	sd	s4,16(sp)
 952:	e456                	sd	s5,8(sp)
 954:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 956:	00000797          	auipc	a5,0x0
 95a:	6ba78793          	addi	a5,a5,1722 # 1010 <base>
 95e:	00000717          	auipc	a4,0x0
 962:	6af73123          	sd	a5,1698(a4) # 1000 <freep>
 966:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 968:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 96c:	b7d1                	j	930 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 96e:	6398                	ld	a4,0(a5)
 970:	e118                	sd	a4,0(a0)
 972:	a899                	j	9c8 <malloc+0xd0>
  hp->s.size = nu;
 974:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 978:	0541                	addi	a0,a0,16
 97a:	ef9ff0ef          	jal	872 <free>
  return freep;
 97e:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 980:	c125                	beqz	a0,9e0 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 982:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 984:	4798                	lw	a4,8(a5)
 986:	03277163          	bgeu	a4,s2,9a8 <malloc+0xb0>
    if (p == freep)
 98a:	6098                	ld	a4,0(s1)
 98c:	853e                	mv	a0,a5
 98e:	fef71ae3          	bne	a4,a5,982 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 992:	8552                	mv	a0,s4
 994:	a1bff0ef          	jal	3ae <sbrk>
  if (p == SBRK_ERROR)
 998:	fd551ee3          	bne	a0,s5,974 <malloc+0x7c>
        return 0;
 99c:	4501                	li	a0,0
 99e:	74a2                	ld	s1,40(sp)
 9a0:	6a42                	ld	s4,16(sp)
 9a2:	6aa2                	ld	s5,8(sp)
 9a4:	6b02                	ld	s6,0(sp)
 9a6:	a03d                	j	9d4 <malloc+0xdc>
 9a8:	74a2                	ld	s1,40(sp)
 9aa:	6a42                	ld	s4,16(sp)
 9ac:	6aa2                	ld	s5,8(sp)
 9ae:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 9b0:	fae90fe3          	beq	s2,a4,96e <malloc+0x76>
        p->s.size -= nunits;
 9b4:	4137073b          	subw	a4,a4,s3
 9b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ba:	02071693          	slli	a3,a4,0x20
 9be:	01c6d713          	srli	a4,a3,0x1c
 9c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c8:	00000717          	auipc	a4,0x0
 9cc:	62a73c23          	sd	a0,1592(a4) # 1000 <freep>
      return (void *)(p + 1);
 9d0:	01078513          	addi	a0,a5,16
  }
}
 9d4:	70e2                	ld	ra,56(sp)
 9d6:	7442                	ld	s0,48(sp)
 9d8:	7902                	ld	s2,32(sp)
 9da:	69e2                	ld	s3,24(sp)
 9dc:	6121                	addi	sp,sp,64
 9de:	8082                	ret
 9e0:	74a2                	ld	s1,40(sp)
 9e2:	6a42                	ld	s4,16(sp)
 9e4:	6aa2                	ld	s5,8(sp)
 9e6:	6b02                	ld	s6,0(sp)
 9e8:	b7f5                	j	9d4 <malloc+0xdc>
