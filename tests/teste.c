#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NUM_FILHOS 4
#define ITERACOES  200000000

// Loop ocupado só para consumir CPU (sem I/O, sem sleep/pause),
// assim o processo nunca dorme e o scheduler não tem motivo pra
// tirar ele de RUNNING a não ser terminar.
void
busy_loop(long n)
{
  volatile long i;
  for (i = 0; i < n; i++)
    ;
}

int
main(void)
{
  int i;

  // ---- Teste 1: getppid() ----
  printf("=== Teste 1: getppid() ===\n");
  printf("Processo atual (PID): %d\n", getpid());
  printf("Processo pai (PPID): %d\n", getppid());

  // ---- Teste 2: ordem de execucao (FCFS / RR) ----
  printf("\n=== Teste 2: Ordem de execucao ===\n");
  printf("Criando %d processos filhos...\n", NUM_FILHOS);

  for (i = 0; i < NUM_FILHOS; i++) {
    int child_pid = fork();

    if (child_pid < 0) {
      printf("erro no fork\n");
      exit(1);
    }

    if (child_pid == 0) {
      // ---- codigo do filho ----
      int meu_pid = getpid();
      int inicio = uptime();

      printf("[PID %d] INICIO em tick %d (pai=%d)\n",
             meu_pid, inicio, getppid());

      busy_loop(ITERACOES);

      int fim = uptime();
      printf("[PID %d] FIM em tick %d (duracao: %d ticks)\n",
             meu_pid, fim, fim - inicio);

      exit(0);
    }

    // ---- codigo do pai: registra o tick de CRIACAO logo apos o fork() ----
    // Esse eh o instante em que o xv6 marca o filho como RUNNABLE,
    // ou seja, quando ele "chega" na fila de prontos.
    int criacao = uptime();
    printf("[PID %d] CRIACAO (chegada) em tick %d\n", child_pid, criacao);
  }

  // pai espera todos os filhos
  for (i = 0; i < NUM_FILHOS; i++) {
    wait(0);
  }

  printf("\nTodos os filhos terminaram.\n");
  exit(0);
}
