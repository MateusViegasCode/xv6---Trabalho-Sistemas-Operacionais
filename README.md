# Projeto de Sistemas Operacionais - Modificações no xv6
**Tema Escolhido:** Tema 2 - Syscall `getppid()` e Algoritmo de Escalonamento FCFS

Integrantes do Grupo

1. Leandro Evaristo De Sousa
2. Mateus Alves Viegas
3. Cauê Fernando Faria Abreu
4. Igor dos Reis Mascarenhas
5. Júlia Yasmin Silva Guimarães
6. Sanmyla Silva Costa

## Descrição das Etapas

## ETAPA 1: Fundamentação
* Apresentação em Slides: Apoio visual (localizado na pasta slides/) para ilustrar a arquitetura que propomos, nossos embasamentos teóricos e mapear quais componentes do kernel serão alterados na próxima etapa.
* Vídeo Explicativo: Gravamos um vídeo (disponível na pasta video/) onde todos os membros do grupo participam ativamente. Nele, nós compartilhamos e explicamos os detalhes técnicos da nossa solução, abordando:
* A motivação e os objetivos centrais do Tema 2.
* O embasamento teórico e a nossa proposta de implementação para a system call getppid() , que nos permitirá mapear e identificar a hierarquia de processos do sistema.
* A lógica e a adaptação do algoritmo de escalonamento FCFS (First-Come, First-Served), pensado para garantir que os processos sejam executados respeitando estritamente a ordem de chegada.

## ETAPA 2: Implementação Prática

Nesta etapa, as propostas da Etapa 1 foram efetivamente implementadas no kernel do xv6, testadas e validadas experimentalmente, com comparação direta contra o escalonador Round Robin original.

* **Código-fonte completo**: disponível na pasta `code/` (árvore inteira do xv6, já com as modificações aplicadas).
* **Programa de testes**: disponível na pasta `tests/` (`teste.c`), junto com os logs brutos das execuções (`fcfs_saida.txt`, `rr_saida.txt`).
* **Relatório técnico final (PDF)**: disponível na pasta `report/`, contendo introdução, arquivos modificados, resultados experimentais, gráficos, análise crítica e conclusões.

### Arquivos modificados no xv6

| Arquivo | O que foi modificado |
|---|---|
| `kernel/syscall.h` | Adicionados os números de chamada de sistema `SYS_getidade` (23) e `SYS_getppid` (24). |
| `kernel/syscall.c` | Adicionados os protótipos `extern` de `sys_getidade()` e `sys_getppid()`, e suas entradas no vetor `syscalls[]`. |
| `kernel/sysproc.c` | Implementada a função `sys_getppid()`, que retorna o PID do processo pai ou 1 caso não tenha pai. |
| `user/user.h` | Adicionados os protótipos `int getidade(void);` e `int getppid(void);`. |
| `user/usys.pl` | Adicionadas as chamadas `entry("getidade")` e `entry("getppid")`, que geram os stubs em assembly (`usys.S`). |
| `kernel/proc.c` | Reescrita da função `scheduler()`: escolhe o processo `RUNNABLE` de menor PID (critério FCFS), em vez de Round Robin. A função `yield()` foi neutralizada (no-op) para remover a preempção por tempo. |
| `user/teste.c` | Programa de teste: valida `getppid()` e demonstra experimentalmente a ordem de execução do escalonador, registrando os ticks de chegada, início e término de cada processo. |

## Como Reproduzir

### Pré-requisitos (uma vez só, na VM Ubuntu)

```bash
sudo apt update
sudo apt install git build-essential gdb-multiarch qemu-system-misc \
    gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu
```

### Clonar e compilar

```bash
git clone <URL_DESTE_REPOSITORIO>
cd <pasta_do_projeto>
make clean
make qemu CPUS=1
```

> **Importante:** usar sempre `CPUS=1`. Com múltiplos núcleos (padrão do Makefile é `CPUS=3`), os processos podem rodar em paralelo de verdade, o que invalida a comparação entre FCFS e Round Robin e corrompe os logs por escrita simultânea no console.

### Rodar o teste

Dentro do shell do xv6:
```
teste
```

Isso executa dois testes:
1. Valida a syscall `getppid()`, imprimindo PID e PPID do processo atual.
2. Cria 4 processos filhos, cada um com um laço de CPU, imprimindo os ticks de chegada, início e término — evidenciando a ordem de execução do escalonador ativo.

Para sair do QEMU: `Ctrl+A`, depois `X`.

### Comparar FCFS vs Round Robin

O `kernel/proc.c` deste repositório está configurado para **FCFS**. Para reproduzir o cenário de comparação, a pasta `kernel/` também inclui duas cópias de referência:

* `kernel/proc_FCFS_backup.c` — versão com o escalonador FCFS implementado pelo grupo (a mesma usada em `kernel/proc.c` por padrão).
* `kernel/proc_RR_backup.c` — versão com o escalonador Round Robin original do xv6, usada como baseline de comparação.

Para rodar cada cenário:

1. Copie o arquivo desejado para `kernel/proc.c`:
   ```bash
   # Para testar o FCFS:
   cp kernel/proc_FCFS_backup.c kernel/proc.c

   # Para testar o Round Robin original:
   cp kernel/proc_RR_backup.c kernel/proc.c
   ```
2. Recompile e rode com um núcleo só:
   ```bash
   make clean
   make qemu CPUS=1
   ```
3. Dentro do shell do xv6, rode `teste` e capture a saída.
4. Repita o processo com o outro arquivo para obter o segundo conjunto de dados.

> Antes de finalizar/entregar, garanta que `kernel/proc.c` esteja copiado a partir de `proc_FCFS_backup.c`, já que o FCFS é a versão oficial do Tema 2.

## Estrutura do Repositório

```
grupoX/
├── README.md
├── slides/
├── video/
├── code/
├── tests/
└── report/
```