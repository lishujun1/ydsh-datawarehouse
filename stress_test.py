import concurrent.futures
import time
import requests

# 假设你的 Flask 后端正在运行
url = "http://localhost:5000/api/trend"

def fetch():
    start = time.time()
    try:
        response = requests.get(url)
        response.raise_for_status()
        return time.time() - start
    except Exception as e:
        return None

def run_test(concurrency):
    print(f"--- 开始测试 {concurrency} 并发 ---")
    start_total = time.time()
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
        results = list(executor.map(lambda _: fetch(), range(concurrency * 3)))
    
    success = [r for r in results if r is not None]
    if success:
        avg = sum(success) / len(success)
        print(f"并发 {concurrency}: 平均响应时间 {avg:.3f}s, 成功率 {len(success)/len(results)*100:.0f}%")
    else:
        print("全部请求失败")

if __name__ == "__main__":
    for c in [1, 3, 5, 10]:
        run_test(c)
        time.sleep(1)