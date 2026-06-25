package com.qiuji.qaiagent.agent;

import java.util.List;

import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;

import com.qiuji.qaiagent.agent.model.AgentState;

import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * ReAct (Reasoning and Acting) 模式的代理抽象类
 * 实现了思考-行动的循环模式
 */
@EqualsAndHashCode(callSuper = true)
@Data
public abstract class ReActAgent extends BaseAgent {

    /**
     * 处理当前状态并决定下一步行动
     *
     * @return 是否需要执行行动，true表示需要执行，false表示不需要执行
     */
    public abstract boolean think();

    /**
     * 执行决定的行动
     *
     * @return 行动执行结果
     */
    public abstract String act();

    /**
     * 执行单个步骤：思考和行动
     *
     * @return 步骤执行结果
     */
    @Override
    public String step() {
        try {
            boolean shouldAct = think();
            if (!shouldAct) {
                // 无需行动时，说明任务已完成（LLM 直接回复或出错）
                setState(AgentState.FINISHED);
                // 返回最后一条助手消息的文本内容
                List<Message> msgs = getMessageList();
                for (int i = msgs.size() - 1; i >= 0; i--) {
                    Message msg = msgs.get(i);
                    if (msg instanceof AssistantMessage assistantMsg) {
                        String text = assistantMsg.getText();
                        if (text != null && !text.isEmpty()) {
                            return text;
                        }
                    }
                }
                return "任务完成";
            }
            return act();
        } catch (Exception e) {
            // 记录异常日志，并停止后续步骤，防止脏消息导致级联错误
            setState(AgentState.ERROR);
            e.printStackTrace();
            return "步骤执行失败: " + e.getMessage();
        }
    }
}