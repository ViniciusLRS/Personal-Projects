import psutil
import time
import os

# Lista de nomes comuns de mineradores (pode ser expandida)
miner_processes = [
    "xmrig", "minerd", "cpuminer", "cgminer", "nicehash", "ethminer", "t-rex", "nbminer", "phoenixminer"
]

def check_high_cpu(threshold=80):
    """Verifica se o uso da CPU está acima de um limite"""
    usage = psutil.cpu_percent(interval=5)
    return usage > threshold

def check_for_miner_processes():
    """Procura por nomes de processos conhecidos de mineração"""
    found = []
    for proc in psutil.process_iter(['pid', 'name']):
        try:
            name = proc.info['name'].lower()
            if any(miner in name for miner in miner_processes):
                found.append((proc.info['pid'], name))
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    return found

def alert(title, msg):
    """Envia uma notificação para o usuário"""
    try:
        if os.name == 'nt':
            from win10toast import ToastNotifier
            toaster = ToastNotifier()
            toaster.show_toast(title, msg, duration=10)
        else:
            print(f"[ALERTA] {title}: {msg}")
    except:
        print(f"[ALERTA] {title}: {msg}")

def main():
    print("🔎 Monitorando atividade suspeita...")
    while True:
        if check_high_cpu():
            print("⚠️ Uso elevado de CPU detectado.")
            miners = check_for_miner_processes()
            if miners:
                for pid, name in miners:
                    alert("⚠️ Minerador detectado", f"Processo suspeito: {name} (PID {pid})")
                    print(f"🚨 Processo suspeito encontrado: {name} (PID {pid})")
            else:
                print("⚠️ Nenhum minerador conhecido, mas CPU está alta.")
        time.sleep(30)

if __name__ == "__main__":
    main()
