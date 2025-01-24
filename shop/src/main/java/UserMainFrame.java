import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class UserMainFrame extends JFrame {
    private String username;

    public UserMainFrame(String username) {
        this.username = username;
        setTitle("用户主界面 - " + username);
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(5, 1));

        JButton viewProductsButton = new JButton("查看商品列表");
        JButton viewCartButton = new JButton("查看购物车");
        JButton viewUserOrdersButton = new JButton("查看订单列表"); // 新增按钮
        JButton applyReturnButton = new JButton("申请退货");
        JButton logoutButton = new JButton("退出登录");

        panel.add(viewProductsButton);
        panel.add(viewCartButton);
        panel.add(viewUserOrdersButton); // 添加“查看订单列表”按钮
        panel.add(applyReturnButton);
        panel.add(logoutButton);

        add(panel);

        // 查看商品列表
        viewProductsButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new ViewProductsFrame(username, false).setVisible(true); // 打开查看商品列表界面
            }
        });

        // 查看购物车
        viewCartButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new ViewCartFrame(username).setVisible(true); // 打开查看购物车界面
            }
        });

        // 查看订单列表
        viewUserOrdersButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new ViewUserOrdersFrame(username).setVisible(true); // 打开查看订单列表界面
            }
        });

        // 退出登录
        logoutButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                dispose(); // 关闭当前窗口
                new LoginFrame().setVisible(true); // 返回登录界面
            }
        });
    }
}