<template>
    <div>
        <h2>View of the Web-App generated with Flutter</h2>

        <iframe src="https://entrancescreen-flutter.firebaseapp.com/">
        </iframe>
        <p><a href="https://entrancescreen-flutter.firebaseapp.com/">Remove frame</a></p>
    </div>
</template>
<script>
  export default {
    name: 'flutter',
    data() {
      return {};
    },
  };
</script>

<style>
    iframe {
        width: 400px;
        height: 800px;
        border: 1px solid gray;
    }
</style>
