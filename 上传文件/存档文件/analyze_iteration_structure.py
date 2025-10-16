import yaml
import json

def analyze_iteration_structure():
    """分析当前迭代节点结构并对比官方文档要求"""
    
    # 读取当前YAML文件
    with open('/home/dify/上传文件/存档文件/1002一键生成短视频-豆包语音优化版-分段处理-最终修复版.yml', 'r', encoding='utf-8') as f:
        workflow_data = yaml.safe_load(f)
    
    # 查找迭代节点
    iteration_node = None
    for node in workflow_data['workflow']['graph']['nodes']:
        if node['data']['type'] == 'iteration':
            iteration_node = node
            break
    
    if iteration_node:
        print("=== 当前迭代节点结构分析 ===")
        print(f"节点ID: {iteration_node['id']}")
        print(f"节点类型: {iteration_node['data']['type']}")
        print(f"节点标题: {iteration_node['data']['title']}")
        
        # 检查是否有graph结构
        if 'graph' in iteration_node['data']:
            print("\n❌ 问题发现: 使用了graph结构")
            print("根据Dify官方文档，迭代节点内部不应该使用graph包装层")
            
            graph_data = iteration_node['data']['graph']
            print(f"内部节点数量: {len(graph_data.get('nodes', []))}")
            print(f"内部连接数量: {len(graph_data.get('edges', []))}")
            
            print("\n内部节点列表:")
            for i, node in enumerate(graph_data.get('nodes', []), 1):
                print(f"  {i}. {node['id']} - {node['data']['title']} ({node['data']['type']})")
        
        # 检查正确的结构字段
        expected_fields = ['iterator_selector', 'output_selector', 'output_type']
        print(f"\n=== 必需字段检查 ===")
        for field in expected_fields:
            if field in iteration_node['data']:
                print(f"✅ {field}: {iteration_node['data'][field]}")
            else:
                print(f"❌ 缺少字段: {field}")
        
        print(f"\n=== 官方文档要求 ===")
        print("根据Dify官方文档，迭代节点应该:")
        print("1. 直接包含子节点，而不是使用graph结构")
        print("2. 子节点应该在迭代节点的data字段下直接定义")
        print("3. 需要正确的iterator_selector指向输入数组")
        print("4. 需要正确的output_selector和output_type定义输出")
        
    else:
        print("❌ 未找到迭代节点")

if __name__ == "__main__":
    analyze_iteration_structure()
