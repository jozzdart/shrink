enum ChunkOp {
  do100, // 0b00
  skip100, // 0b01
  do1000, // 0b10
  skip1000 // 0b11
}

int chunkSize(ChunkOp op) {
  switch (op) {
    case ChunkOp.do100:
    case ChunkOp.skip100:
      return 100;
    case ChunkOp.do1000:
    case ChunkOp.skip1000:
      return 1000;
  }
}
