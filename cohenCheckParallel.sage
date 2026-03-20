# Library imports:
from sage.all import *
import time
import multiprocessing as mp
import argparse
import os

from generateQuandles import isCohen, findOrbits

# load("generateQuandles.sage")

# M = Matrix(ZZ, 12, 12, lambda i, j: i if True else -1)

# print(M)

# start = time.perf_counter()
# isCohen(M)
# finish = time.perf_counter()



# print(finish - start)



def processFunc(inputQueue, outputQueue, n):
     quandle = Matrix(ZZ, n, n)
     number = 0
     pid = os.getpid()

     while True:
          block = inputQueue.get()

          if block is None:
               break
               
          # Read into a Matrix Object
          for i in range(n):
               row = [int(item) for item in block[i].strip().split(",")]
               
               for j in range(n):
                    quandle[i, j] = row[j] - 1
     
          # Check Cohen
          # print(quandle)
          if isCohen(quandle):
               # print("is cohen")
               outputQueue.put(Matrix(quandle))

          number += 1
          print(f"{pid}: Processed {number}")


def outputFunc(outputPath, outputQueue, n):
     ones = Matrix(n, n, lambda i, j: 1)

     with open(outputPath, "w") as file:
          while True:
               quandle = outputQueue.get()

               if quandle is None:
                    break
                    
               quandle = quandle + ones
               # Write to file
               file.write(str(findOrbits(quandle)))
               file.write("\n")
               file.write(str(quandle))
               file.write("\n\n")




def readHelper(filename, inputQueue):
     with open(filename, "r") as f:
          block = []
          for line in f:
               if line.startswith("Quandle") and len(block) != 0: # Reached next Quandle
                    inputQueue.put(block[1:-1])
                    block = []

               block.append(line)

          # Save the final Quandle too
          if block:
                    inputQueue.put(block[1:-1])
          

     # signal termination
     for _ in range(numProcess):
          inputQueue.put(None)




if __name__ == "__main__":
     parser = argparse.ArgumentParser()

     parser.add_argument(
          "-o", "--output",
          help="Output file name"
     )

     parser.add_argument(
          "-n", "--order",
          #required=True,
          help="Order of quandles to generate"
     )
     
     parser.add_argument(
          "-f", "--file",
          help="Path to input file"
     )
     args = parser.parse_args()

     outputPath = args.output
     inputFile = args.file
     n = int(args.order)

     start = time.perf_counter()

     mp.set_start_method("spawn")

     # Make process for writing output list to disk
     outputQueue = mp.Queue(maxsize = 30000)
     outputProc = mp.Process(target=outputFunc, args=(outputPath, outputQueue, n))
     outputProc.start()


     # Make 16 processes
     inputQueue = mp.Queue(maxsize = 30000)
     numProcess = 25
     workers = []
     for _ in range(numProcess):
          p = mp.Process(target=processFunc, args=(inputQueue, outputQueue, n))
          p.start()
          workers.append(p)

          
     readHelper(inputFile, inputQueue)
     # Load lines of a quandle, push into queue for workers to process
          # Send in batches of lines

     
     for w in workers:
          w.join()


     outputQueue.put(None)

     outputProc.join()

     print(f"Elapsed time: {(time.perf_counter() - start) / 60} minutes")






