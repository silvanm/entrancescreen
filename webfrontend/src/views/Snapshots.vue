<template>
    <div>
        <div class="snapshot" v-bind:key="img.filename" v-for="img in images">
            <face-image :person-list="personList" :obj="img"/>
        </div>

    </div>
</template>

<script>
  import { storage } from '../firebase/storage';
  import FaceImage from '../components/FaceImage';
  import { db } from '../firebase/firestore';
  import { PersonList } from '../models';

  export default {
    name: 'ImageList',
    components: {FaceImage},
    data() {
      return {
        images: [],
        personList: null
      };
    },

    mounted() {
      this.personList = new PersonList();
      this.personList.load();

      var storageRef = storage.ref();

      storageRef.listAll().then((res) => {

        db.collection('faceimages')
          .get()
          .then(querySnapshot => {
            const faceimages = querySnapshot.docs.map(doc => doc.data());
            let map = [];
            faceimages.forEach((o) => {
              map[o.filename] = o;
            });

            res.items.forEach((itemRef) => {
              let currentImage = {
                loading: true,
                filename: itemRef.fullPath,
                createdAt: null,
                url: null,
                facecount: null,
                firestoreRef: itemRef,
                firestoreObj: map[itemRef.fullPath]
              };
              this.images.push(currentImage);
            });
            this.images.reverse();
          });
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
