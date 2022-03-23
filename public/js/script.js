
document.querySelector("#sign-up").style.animationDelay = `-${new Date().getTime() % 11000}ms`;

console.log(Math.round(new Date().getTime()) % 11000);

