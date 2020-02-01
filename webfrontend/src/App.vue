<template>
    <div id="app">
        <h1>Erlenstrasse 3C - Entrance-App</h1>

        <nav>
            <a href="/">Images</a>
            <a href="/persons">Manage Persons</a>
            <a href="/flutter">Frontend</a></nav>
        <div>
            <router-view></router-view>
        </div>
    </div>
</template>

<script>
    export default {
    }
</script>

<style lang="scss">
    body {
        background-color: black;
        color: white;
        margin: 10px;
    }

    #app {
        font-family: Helvetica, Arial, sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;

        > div {
            margin: 20px 0;
        }
    }

    #nav {
        padding: 30px;
    }

    nav a {
        font-weight: bold;
        color: cornflowerblue;
        padding: 5px 5px 5px 0 ;
    }

    #nav a.router-link-exact-active {
        color: #42b983;
    }

    button, input {
        font-size: 14px;
        padding: 5px;
    }
</style>
