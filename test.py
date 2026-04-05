# Test ssh file system
import os

# Test the 3 layers
from etl.bronze import rebuild_bronze_layer
from etl.silver import rebuild_silver_layer
from etl.gold import rebuild_gold_layer

print("")
print("="*20, " BRONZE LAYER ", "="*20)
rebuild_bronze_layer()

print("")
print("="*20, " SILVER LAYER ", "="*20)
rebuild_silver_layer()

print("")
print("="*20, " GOLD LAYER ", "="*20)
rebuild_gold_layer()
