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

### ETAPA 1: Fundamentação
* Apresentação em Slides: Apoio visual (localizado na pasta slides/) para ilustrar a arquitetura que propomos, nossos embasamentos teóricos e mapear quais componentes do kernel serão alterados na próxima etapa.
* Vídeo Explicativo: Gravamos um vídeo (disponível na pasta video/) onde todos os membros do grupo participam ativamente. Nele, nós compartilhamos e explicamos os detalhes técnicos da nossa solução, abordando:
  .A motivação e os objetivos centrais do Tema 2.
  .O embasamento teórico e a nossa proposta de implementação para a system call getppid() , que nos permitirá mapear e identificar a hierarquia de processos do sistema.
  .A lógica e a adaptação do algoritmo de escalonamento FCFS (First-Come, First-Served), pensado para garantir que os processos sejam executados respeitando estritamente a ordem de chegada.
