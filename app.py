import streamlit as st
import mysql.connector
from datetime import date
import pandas as pd

# ==========================
# Cấu hình đăng nhập
# ==========================
USERS = {
    "read_user": {"password": "ReadOnlyPass!", "role": "Reader"},
    "staff_user": {"password": "StaffPass!", "role": "Staff"},
    "report_user": {"password": "ReportPass!", "role": "Reporter"}
}

# ==========================
# Kết nối CSDL
# ==========================
def connect_to_db(user, password):
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='yourpassword',
        database='mytinylibrary'
    )

# ==========================
# Gọi stored procedure chung
# ==========================
def call_procedure(user, password, proc_name, params=()):
    conn = connect_to_db(user, password)
    cursor = conn.cursor()
    cursor.callproc(proc_name, params)
    for result in cursor.stored_results():
        rows = result.fetchall()
        columns = result.column_names
        if rows:
            st.dataframe(pd.DataFrame(rows, columns=columns))
        else:
            st.info("No Information.")
    cursor.close()
    conn.close()

# ==========================
# Mượn sách
# ==========================
def borrow_book(user, password):
    st.subheader("📕 Borrow Book")
    reader_id = st.number_input("Reader ID", min_value=1)
    book_id = st.number_input("Book ID", min_value=1)
    staff_id = st.number_input("Borrow Staff ID", min_value=1)
    borrow_date = st.date_input("Borrow Date", value=date.today())

    if st.button("Borrow"):
        conn = connect_to_db(user, password)
        cursor = conn.cursor()
        args = [reader_id, book_id, staff_id, borrow_date, ""]
        result = cursor.callproc("borrow_book", args)
        st.success(f"Result: {result[4]}")
        conn.commit()
        cursor.close()
        conn.close()

# ==========================
# Trả sách
# ==========================
def return_book(user, password):
    st.subheader("📗 Return Book")
    borrow_id = st.number_input("Borrow ID", min_value=1)
    return_staff_id = st.number_input("Return Staff ID", min_value=1)
    return_date = st.date_input("Return Date", value=date.today())

    if st.button("Return"):
        conn = connect_to_db(user, password)
        cursor = conn.cursor()
        args = [borrow_id, return_staff_id, return_date, ""]
        result = cursor.callproc("return_book", args)
        st.success(f"Result: {result[3]}")
        conn.commit()
        cursor.close()
        conn.close()

# ==========================
# Giao diện chính
# ==========================
def main_interface(username, role):
    st.sidebar.success(f"Login As: {role}")
    
    # Thêm nút đăng xuất
    if st.sidebar.button("Sign Out"):
        st.session_state.logged_in = False
        st.session_state.username = None
        st.session_state.role = None
        st.rerun()

    if role == "Reader":
        menu = st.sidebar.selectbox("Functions", [
            "Book List", "Currently Borrowed Books",
            "Book Information by Book ID", "Reader Information by Reader ID",
            "Borrowing History of Reader ID"
        ])
    elif role == "Reporter":
        menu = st.sidebar.selectbox("Functions", [
            "Overdue Report", "Currently Borrowed Books",
        ])
    else:  # Staff
        menu = st.sidebar.selectbox("Functions", [
            "Borrow Book", "Return Book", "Overdue Report", "Book List",
            "Currently Borrowed Books", "Book Information by Book ID",
            "Reader Information by Reader ID", "Borrowing History of Reader ID", "Borrowing History of Book ID"
        ])

    # Chức năng theo menu
    if menu == "Borrow Book":
        borrow_book(username, USERS[username]["password"])
    elif menu == "Return Book":
        return_book(username, USERS[username]["password"])
    elif menu == "Overdue Report":
        call_procedure(username, USERS[username]["password"], "overdue_report")
    elif menu == "Book List":
        call_procedure(username, USERS[username]["password"], "get_all_books")
    elif menu == "Currently Borrowed Books":
        call_procedure(username, USERS[username]["password"], "get_currently_borrowed_books")
    elif menu == "Book Information by Book ID":
        book_id = st.number_input("Book ID", min_value=1)
        if st.button("Find"):
            call_procedure(username, USERS[username]["password"], "get_book_by_id", [book_id])
    elif menu == "Reader Information by Reader ID":
        reader_id = st.number_input("Reader ID", min_value=1)
        if st.button("Find"):
            call_procedure(username, USERS[username]["password"], "get_reader_by_id", [reader_id])
    elif menu == "Borrowing History of Reader ID":
        reader_id = st.number_input("Reader ID", min_value=1)
        if st.button("Find"):
            call_procedure(username, USERS[username]["password"], "get_borrowings_of_readerid", [reader_id])
    elif menu == "Borrowing History of Book ID":
        book_id = st.number_input("Book ID", min_value=1)
        if st.button("Find"):
            call_procedure(username, USERS[username]["password"], "get_borrowings_of_bookid", [book_id])

# ==========================
# Đăng nhập
# ==========================
def login():
    st.title("📚 MyTinyLibrary - Login System")
    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        user = USERS.get(username)
        if user and user["password"] == password:
            st.session_state.logged_in = True
            st.session_state.username = username
            st.session_state.role = user["role"]
            st.rerun()
        else:
            st.error("Invalid username or password.")

# ==========================
# Khởi chạy
# ==========================
if "logged_in" not in st.session_state:
    st.session_state.logged_in = False

if not st.session_state.logged_in:
    login()
else:
    main_interface(st.session_state.username, st.session_state.role)
