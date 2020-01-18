<template>
    <div class="image" v-observe-visibility="visibilityChanged">
        <div class="full-view" v-if="showFull">
            <div id="selection" :style="{ left:
            this.selection.topleft[0] + 'px',
            top:
            this.selection.topleft[1] + 'px',
            width:
            (this.selection.bottomright[0] - this.selection.topleft[0]) + 'px',
            height:
            (this.selection.bottomright[1] - this.selection.topleft[1]) + 'px',
            }"></div>
            <div v-on:click="showFull=false">X</div>
            <img :src="obj.url"
                 draggable="false"
            >
            <div
                    id="sensor"
                    v-on:mousedown="dragStart($event)"
                    v-on:mousemove="drag($event)"
                    v-on:mouseup="dragEnd($event)"
                    v-on:mouseout="dragEnd($event)"></div>
            <pre>{{statusMessage}}</pre>
        </div>
        <img class="thumbnail" :src="obj.url" v-on:click="showFull=true;analyze()"

        >
        <div class="created-at">{{displayDate}} - {{obj.facecount}}</div>

    </div>
</template>

<script>
  import moment from 'moment';
  import Vue from 'vue';
  import azureRequest from '@/azureRequest';

  export default {
    name: 'Snapshots',
    props: {
      obj: Object
    },
    data() {
      return {
        showFull: false,
        statusMessage: 'loading...',
        dragging: false,
        selection: {
          topleft: [0, 0],
          bottomright: [0, 0],
        }
      };
    },
    computed: {
      displayDate() {
        if (this.obj.createdAt === null) {
          return '';
        } else {
          return moment(this.obj.createdAt).format('DD.MM.YYYY HH:mm:ss');
        }
      }
    },
    methods: {
      load() {
        this.obj.firestoreRef.getDownloadURL().then((res) => {
          this.obj.url = res;
        });
        this.obj.firestoreRef.getMetadata().then((res) => {
          Vue.set(this.obj, 'createdAt', new Date(res.timeCreated));
          Vue.set(this.obj, 'facecount', res.customMetadata.facecount);
        });
      },
      visibilityChanged(isVisible) {
        if (isVisible && this.obj.url == null) {
          this.load();
        }
      },
      analyze() {

        // Request parameters.
        var params = {
          'returnFaceId': 'true',
          'returnFaceLandmarks': 'false',
          'recognitionModel': 'recognition_02',
          'returnRecognitionModel': true,
          'returnFaceAttributes':
            'age,gender,headPose,smile,facialHair,glasses,emotion,' +
            'hair,makeup,occlusion,accessories,blur,exposure,noise'
        };

        azureRequest('detect', params, {url: this.obj.url})
          .then((data) => {
            // Show formatted JSON on webpage.
            this.statusMessage = data.data;
          });
      },
      /* eslint no-console: 0 */
      dragStart(e) {
        this.dragging = true;
        this.selection.topleft = this.selection.bottomright = this.getRelativeCoords(e);
        return false;
      },
      /* eslint no-console: 0 */
      drag(e) {
        if (this.dragging) {
          this.selection.bottomright = this.getRelativeCoords(e);
          return false;
        }
      },
      /* eslint no-console: 0 */
      dragEnd(e) {
        this.dragging = false;
        this.getRelativeCoords(e);
        return false;
      },
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
      }
    }
  };
</script>

<style scoped>
    .image {
        padding: 5px;
        min-height: 100px;

    }

    img.thumbnail {
        width: 100px;
        height: 150px;
        background-color: lightgray;
        cursor: pointer;
    }

    .full-view img {
        max-height: 800px;
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
        border: 1px solid red;
        background: transparent;
        user-select: none;
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
