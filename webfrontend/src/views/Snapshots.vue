<template>
    <div>
        <div class="snapshot" v-bind:key="img.filename" v-for="img in images">
            <face-image :obj="img"/>
        </div>

    </div>
</template>

<script>
  import { storage } from '../firebase/storage';
  import FaceImage from '../components/FaceImage';

  export default {
    name: 'ImageList',
    components: {FaceImage},
    data() {
      return {
        images: []
      };
    },
    mounted() {
      // Create a storage reference from our storage service
      var storageRef = storage.ref();

      // Find all the prefixes and items.
      storageRef.listAll().then((res) => {
        res.items.forEach((itemRef) => {
          let currentImage = {
            loading: true,
            filename: itemRef.fullPath,
            createdAt: null,
            url: null,
            facecount: null,
            firestoreRef: itemRef
          };
          this.images.push(currentImage);
        });
        this.images.reverse();
      }).catch(function (error) {
        throw error;
      });
    }
  };
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    .snapshot {
        display: inline-block;
    }

</style>
