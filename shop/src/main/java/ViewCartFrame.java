import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class ViewCartFrame extends JFrame {
    private String username;
    private JList<String> cartList;
    private DefaultListModel<String> listModel;
    private JTextField addressField; // 文本框输入收货地址
    private JComboBox<String> paymentMethodComboBox;

    public ViewCartFrame(String username) {
        this.username = username;
        setTitle("购物车 - " + username);
        setSize(600, 500); // 增加高度以容纳新组件
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new BorderLayout());

        // 购物车列表
        listModel = new DefaultListModel<>();
        cartList = new JList<>(listModel);
        JScrollPane scrollPane = new JScrollPane(cartList);
        panel.add(scrollPane, BorderLayout.CENTER);

        // 操作按钮和地址输入
        JPanel controlPanel = new JPanel();
        controlPanel.setLayout(new GridLayout(4, 2));

        // 收货地址输入
        controlPanel.add(new JLabel("输入收货地址:"));
        addressField = new JTextField();
        controlPanel.add(addressField);

        // 支付方式选择
        controlPanel.add(new JLabel("选择支付方式:"));
        paymentMethodComboBox = new JComboBox<>(new String[]{"支付宝", "微信支付", "银行卡"});
        controlPanel.add(paymentMethodComboBox);

        // 删除商品按钮
        JButton removeButton = new JButton("删除商品");
        controlPanel.add(removeButton);

        // 支付按钮
        JButton payButton = new JButton("下单并支付");
        controlPanel.add(payButton);

        panel.add(controlPanel, BorderLayout.SOUTH);

        add(panel);

        // 加载购物车
        loadCart();

        // 删除商品事件
        removeButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedItem = cartList.getSelectedValue();
                if (selectedItem != null) {
                    int cartId = Integer.parseInt(selectedItem.split(" - ")[0].replace("购物车ID: ", ""));
                    removeFromCart(cartId);
                } else {
                    JOptionPane.showMessageDialog(ViewCartFrame.this, "请选择一个商品！");
                }
            }
        });

        // 支付事件（整合创建订单逻辑）
        payButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String deliveryAddress = addressField.getText();
                if (deliveryAddress == null || deliveryAddress.isEmpty()) {
                    JOptionPane.showMessageDialog(ViewCartFrame.this, "请输入收货地址！");
                    return;
                }

                // 创建订单并支付
                createOrderAndPay(deliveryAddress);
            }
        });
    }

    // 加载购物车
    private void loadCart() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call GetCartItems(?)}");
            cstmt.setInt(1, getUserId(username)); // 获取用户ID
            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                String cartItem = "购物车ID: " + rs.getInt("CartID") + " - " +
                        rs.getString("ProductName") + " - 数量: " + rs.getInt("Quantity");
                listModel.addElement(cartItem);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "加载购物车失败: " + ex.getMessage());
        }
    }

    // 删除商品
    private void removeFromCart(int cartId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call RemoveCartItem(?)}");
            cstmt.setInt(1, cartId);
            cstmt.execute();

            listModel.removeElement("购物车ID: " + cartId);
            JOptionPane.showMessageDialog(this, "商品已从购物车中移除！");
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "删除商品失败: " + ex.getMessage());
        }
    }

    // 创建订单并支付
    private void createOrderAndPay(String deliveryAddress) {
        String paymentMethod = (String) paymentMethodComboBox.getSelectedItem();
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            JOptionPane.showMessageDialog(this, "请选择支付方式！");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            // 创建订单
            CallableStatement createOrderStmt = conn.prepareCall("{call CreateOrderWithPromotion(?, ?)}");
            createOrderStmt.setInt(1, getUserId(username)); // 获取用户ID
            createOrderStmt.setString(2, deliveryAddress); // 输入的收货地址
            createOrderStmt.execute();

            // 获取最新的订单ID
            PreparedStatement pstmt = conn.prepareStatement(
                    "SELECT TOP 1 OrderID FROM Orders WHERE UserID = ? AND Status = '待支付' ORDER BY OrderID DESC");
            pstmt.setInt(1, getUserId(username));
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int orderId = rs.getInt("OrderID");

                // 调用支付存储过程
                CallableStatement payStmt = conn.prepareCall("{call CreatePayment(?, ?)}");
                payStmt.setInt(1, orderId);              // @OrderID (INT)
                payStmt.setString(2, paymentMethod);     // @PaymentMethod (NVARCHAR)
                payStmt.execute();

                // 更新订单状态为“已支付”
                CallableStatement updateStmt = conn.prepareCall("{call UpdateOrderStatus(?)}");
                updateStmt.setInt(1, orderId);           // @OrderID (INT)
                updateStmt.execute();

                JOptionPane.showMessageDialog(this, "订单创建并支付成功！");
                dispose(); // 关闭购物车界面
            } else {
                JOptionPane.showMessageDialog(this, "没有待支付的订单！");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "订单创建或支付失败: " + ex.getMessage());
        }
    }

    // 根据用户名获取用户ID
    private int getUserId(String username) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement pstmt = conn.prepareStatement("SELECT UserID FROM Users WHERE Username = ?");
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("UserID");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1;
    }
}