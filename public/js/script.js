let signup_btn = document.querySelector("#sign-up");
let account_btn = document.querySelector("#account");
if (signup_btn) {
    signup_btn.style.animationDelay = `-${new Date().getTime() % 11000}ms`;
}
if (account_btn) {
    account_btn.style.animationDelay = `-${new Date().getTime() % 11000}ms`;
}
