<template>
    <div>
        <datepicker calendar-class="datepicker" :inline="true" v-model="date" v-on:input="updateImages"></datepicker>
        <div class="snapshot" v-bind:key="img.id" v-for="img in images">
            <face-image :person-list="personList" :obj="img"/>
        </div>
    </div>
</template>

<script>
  import { storage } from '../firebase/storage';
  import FaceImage from '../components/FaceImage';
  import { db } from '../firebase/firestore';
  import { PersonList } from '../models';
  import Datepicker from 'vuejs-datepicker';

  export default {
    name: 'ImageList',
    components: {FaceImage, Datepicker},
    data() {
      return {
        date: new Date(new Date().setHours(0, 0, 0, 0)),
        images: [],
        personList: null
      };
    },
    mounted() {
      this.personList = new PersonList();
      this.personList.load();
      this.updateImages();
    },
    methods: {
      updateImages() {
        this.images = [];
        let thisDay = this.date;
        let nextDay = new Date(thisDay.getFullYear(), thisDay.getMonth(), thisDay.getDate() + 1);

        db.collection('faceimages')
          .where('createdAt', '>', thisDay)
          .where('createdAt', '<', nextDay)
          .orderBy('createdAt', 'desc')
          .get()
          .then(querySnapshot => {
            /* eslint no-console: 0 */
            console.log(`Read ${querySnapshot.size} items between ${thisDay} and ${nextDay}`);

            querySnapshot.forEach((o) => {
              let d = o.data();
              let currentImage = {
                loading: true,
                filename: d.filename,
                createdAt: d.createdAt.toDate(),
                url: null,
                facecount: null,
                storageRef: storage.refFromURL(`gs://${process.env.VUE_APP_FIREBASE_STORAGE_BUCKET}/${d.filename}`),
                firestoreObj: d,
                status: d.status
              };
              this.images.push(currentImage);
            });
          });

      },
    }
  };
</script>

<style lang="scss">
    .snapshot {
        display: inline-block;
    }

    .datepicker {
        float: left;
        background-color: black !important;
        border: 1px solid gray !important;
        margin-right: 5px;
    }
</style>
