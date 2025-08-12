import sys
import random

def array_generator(tipo, dimensione):
    """Genera un array in base al tipo e alla dimensione specificati."""
    
    # Imposta un seed fisso per rendere i risultati ripetibili
    random.seed(42)
    
    # 1. Array Casuale (numeri tra 1 e dimensione * 2)
    if tipo == "casuale":
        return [str(random.randint(1, dimensione * 2)) for _ in range(dimensione)]
        
    # 2. Array Ordinato
    arr = list(range(1, dimensione + 1))
    
    # 3. Array Ordinato al Contrario
    if tipo == "inverso":
        return [str(x) for x in reversed(arr)]
        
    # 4. Array Quasi Ordinato
    if tipo == "quasi_ordinato":
        # Scambia il 5% degli elementi
        for _ in range(dimensione // 20):
            idx1, idx2 = random.sample(range(dimensione), 2)
            arr[idx1], arr[idx2] = arr[idx2], arr[idx1]
        return [str(x) for x in arr]
        
    # 5. Array con Molti Duplicati (numeri tra 1 e dimensione/10)
    if tipo == "duplicati":
        return [str(random.randint(1, max(1, dimensione // 10))) for _ in range(dimensione)]
        
    return []

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python3 array_generator.py <tipo> <dimensione>")
        sys.exit(1)
        
    tipo_array = sys.argv[1]
    dimensione_array = int(sys.argv[2])
    
    array_generato = array_generator(tipo_array, dimensione_array)
    
    # Stampa l'array come stringa separata da virgole
    print(",".join(array_generato))