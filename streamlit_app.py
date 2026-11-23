import streamlit as st
from nl2sql import nl2sql
from streamlit_echarts import st_echarts

st.set_page_config(layout="wide", page_title="云购生活智能问数")
st.title("云购生活 · 智能问数")

if "history" not in st.session_state:
    st.session_state.history = []

with st.sidebar:
    st.header("历史对话")
    for h in st.session_state.history:
        st.caption("Q: " + h["q"])
        st.code(h["sql"], language="sql")

q = st.chat_input("例如：各渠道GMV分布 / 销量最高的前5个品类")
if q:
    with st.status("处理中...", expanded=True) as status:
        st.write("正在生成 SQL...")
        try:
            sql, df = nl2sql(q)
            st.write("SQL 生成完成，正在执行...")
            st.session_state.history.append({"q": q, "sql": sql})
            status.update(label="完成", state="complete")
        except Exception as e:
            status.update(label="失败", state="error")
            st.error(str(e))
            st.stop()

    st.subheader("生成的 SQL")
    st.code(sql, language="sql")
    st.subheader("查询结果")
    st.dataframe(df)

    if len(df) > 0 and len(df.columns) >= 2:
        chart_type = "bar" if len(df) <= 20 else "line"
        option = {
            "tooltip": {"trigger": "axis"},
            "xAxis": {"type": "category", "data": df.iloc[:, 0].astype(str).tolist()},
            "yAxis": {"type": "value"},
            "series": [{"type": chart_type, "data": df.iloc[:, 1].tolist()}],
        }
        st_echarts(option, height="400px")