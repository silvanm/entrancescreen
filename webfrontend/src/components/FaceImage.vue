<template>
    <div :class="classObj" v-observe-visibility="visibilityChanged">
        <div class="full-view" v-if="showFull">
            <div id="selection" :class="selectionClass" :style="{ left:
            this.selection.topleft[0] + 'px',
            top:
            this.selection.topleft[1] + 'px',
            width:
            (this.selection.bottomright[0] - this.selection.topleft[0]) + 'px',
            height:
            (this.selection.bottomright[1] - this.selection.topleft[1]) + 'px',
            }"></div>
            <div v-on:click="showFull=false">Close</div>
            <img ref="fullimage" :src="obj.url" v-on:load="updateImageScale();analyze()"
                 v-on:click="showFull=false">
            <person-selector v-if="selectingPerson"
                             :x="this.selection.topleft[0]"
                             :y="this.selection.bottomright[1]"
                             v-on:personSelect="personSelected($event)"
            ></person-selector>
            <button @click="identify" v-if="detectedFaceId">Identify</button>
            <pre>{{statusMessage}}</pre>
        </div>
        <img class="thumbnail" :src="obj.url" v-on:click="showFull=true;"

        >
        <div class="created-at">{{displayDate}}
            {{identifiedPerson}}
        </div>
    </div>
</template>

<script>
  import moment from 'moment';
  import Vue from 'vue';
  import { azureRequest, faceDetect } from '@/azureRequest';
  import PersonSelector from './PersonSelector';
  import config from '../config';
  import { db } from '../firebase/firestore';
  import { PersonList } from '../models';

  export default {
    name: 'Snapshots',
    components: {PersonSelector},
    props: {
      obj: Object,
      personList: PersonList,
    },
    data() {
      return {
        showFull: false,
        statusMessage: 'loading...',
        dragging: false,
        selection: {
          topleft: [0, 0],
          bottomright: [0, 0],
        },
        imageScale: null,
        selectingPerson: false,
        selectionClass: 'initial',
        detectedFaceId: null,
      };
    },
    computed: {
      displayDate() {
        if (this.obj.createdAt === null) {
          return '';
        } else {
          return moment(this.obj.createdAt).format('HH:mm:ss');
        }
      },
      status() {
        try {
          return this.obj.firestoreObj.status;
        } catch (e) {
          return '';
        }
      },
      classObj() {
        const classObj = {
          'image': true,
        };
        classObj[this.status] = true;
        return classObj;
      },
      identifiedPerson() {
        if ('faceIdData' in this.obj.firestoreObj) {
          return this.personList.getById(this.obj.firestoreObj.faceIdData[0].candidates[0].personId).name;
        } else {
          return '';
        }
      }
    },
    updated() {
      this.updateImageScale();
    },
    methods: {
      load() {
        this.obj.storageRef.getDownloadURL().then((res) => {
          this.obj.url = res;
        });
        this.obj.storageRef.getMetadata().then((res) => {
          Vue.set(this.obj, 'createdAt', new Date(res.timeCreated));
          if ('facecount' in res.customMetadata) {
            Vue.set(this.obj, 'facecount', res.customMetadata.facecount);
          }
        });
      },
      visibilityChanged(isVisible) {
        if (isVisible && this.obj.url == null) {
          this.load();
        }
      },
      updateImageScale() {
        if (this.$refs.fullimage) {
          this.imageScale = this.$refs.fullimage.naturalWidth / this.$refs.fullimage.clientWidth;
        } else {
          this.imageScale = null;
        }
      },
      analyze() {
        faceDetect(this.obj, db,
          (data) => {
            // Show formatted JSON on webpage.
            this.statusMessage = data.data;
            if (data.data.length === 1) {
              let r = data.data[0].faceRectangle;
              this.detectedFaceId = data.data[0].faceId;
              this.selection.topleft = [r.left / this.imageScale, r.top / this.imageScale];
              this.selection.bottomright = [
                (r.left + r.width) / this.imageScale,
                (r.top + r.height) / this.imageScale];
              this.selectingPerson = true;
              // Identify face
              this.identify();
            }
          }
        );
      },
      async personSelected(personId) {
        const response = await azureRequest(`persongroups/${config.persongroupId}/persons/${personId}/persistedFaces`,
          {detectionModel: 'detection_02'}, {url: this.obj.url});
        this.statusMessage = response.data.statusMessage;
        this.selectingPerson = false;
        this.selectionClass = 'sent';

        // Update the state in firebase
        const rec = {...this.obj.firestoreObj};
        rec.status = 'sent';

        db.collection('faceimages')
          .doc(this.obj.firestoreObj.id)
          .set(rec)
          .then(() => {
            this.obj.firestoreObj.status = 'sent';
            console.log('faceimages-updated!');
          });

        /* eslint no-console: 0 */
      },
      /**
       * Get the event's coordinate relative to the parent image
       * @param e
       * @returns {number[]}
       */
      getRelativeCoords(e) {
        const position = {
          x: e.pageX,
          y: e.pageY
        };

        const offset = {
          left: e.target.offsetLeft,
          top: e.target.offsetTop
        };

        let reference = e.target.offsetParent;

        while (reference) {
          offset.left += reference.offsetLeft;
          offset.top += reference.offsetTop;
          reference = reference.offsetParent;
        }

        return [
          position.x - offset.left,
          position.y - offset.top
        ];
      },
      async identify() {
        const response = await azureRequest('identify',
          [], {
            'faceIds': [this.detectedFaceId,],
            'personGroupId': config.persongroupId
          });
        let out = '';
        response.data[0].candidates.forEach((o) => {
          out += this.personList.getById(o.personId).name + ': ' + o.confidence + '\n';
        });
        this.statusMessage = out;
      }
    }
  };
</script>

<style scoped lang="scss">
    .image {
        padding: 5px;
        min-height: 100px;

        &.detected {
            border: 2px solid yellow;
        }

        &.identified {
            border: 2px solid green;
        }
    }

    img.thumbnail {
        width: 100px;
        height: 150px;
        background-color: lightgray;
        cursor: pointer;
    }

    .full-view img {
        max-height: 500px;
    }

    .full-view {
        border: 1px solid black;
        background-color: white;
        position: absolute;
        z-index: 5;
    }

    .full-view div {
        right: 0;
        position: absolute;
        background-color: white;
        z-index: 6;
        cursor: pointer;
    }

    .full-view img {
    }

    #selection {
        position: absolute;
        z-index: 7;
        border: 2px solid red;
        background: transparent;
        user-select: none;

        &.sent {
            border-color: green;
        }
    }

    #sensor {
        position: absolute;
        z-index: 8;
        background: transparent;
        top: 0;
        width: 100%;
        height: 100%;
    }

    .created-at {
        font-size: 10px;
    }
</style>
