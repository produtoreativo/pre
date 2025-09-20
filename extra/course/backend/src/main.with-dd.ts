import { readyTracer } from './dd-trace-init';
import bootstrap from './bootstrap';

async function main() {
  await readyTracer();
  await bootstrap();
}

main();
