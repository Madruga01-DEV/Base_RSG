const { createApp, ref, reactive, onMounted } = Vue;

const app = createApp({
    setup() {
        const isVisible = ref(false);
        const showNoEntity = ref(false);
        const showCopyFlash = ref(false);
        const copyMessage = ref('');

        const entityInfo = reactive({
            entity: 0,
            hash: 0,
            hashStr: '',
            coords: { x: 0, y: 0, z: 0 },
            rotation: { x: 0, y: 0, z: 0 },
            type: '',
            networkId: 'N/A',
            heading: 0
        });

        const formatCoords = (coords) => {
            if (!coords) return '-';
            return `vector3(${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)})`;
        };

        const formatHeading = (heading) => {
            if (heading === undefined || heading === null) return '-';
            return heading.toFixed(2);
        };

        const copyFormattedInfo = (format) => {
            if (!entityInfo) return;
            
            let text = '';
            switch(format) {
                case 'model':
                    text = entityInfo.hashStr;
                    break;
                case 'coords':
                    text = formatCoords(entityInfo.coords);
                    break;
                case 'rotation':
                    text = formatCoords(entityInfo.rotation);
                    break;
                case 'heading':
                    text = formatHeading(entityInfo.heading);
                    break;
                case 'all':
                    text = `Entity: ${entityInfo.entity}\nType: ${entityInfo.type}\nModel Hash: ${entityInfo.hashStr}\nNetwork ID: ${entityInfo.networkId}\nCoords: ${formatCoords(entityInfo.coords)}\nRotation: ${formatCoords(entityInfo.rotation)}\nHeading: ${formatHeading(entityInfo.heading)}`;
                    break;
                default:
                    return;
            }
            
            fetch(`https://${GetParentResourceName()}/copyToClipboard`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ text: text, format: format })
            });
        };

        const execCopyToClipboard = (text) => {
            const tempInput = document.createElement('textarea');
            tempInput.value = text;
            document.body.appendChild(tempInput);
            
            tempInput.select();
            let success = false;
            
            try {
                success = document.execCommand('copy');
            } catch (err) {
                console.error('Failed to copy: ', err);
            }
            
            document.body.removeChild(tempInput);
            
            fetch(`https://${GetParentResourceName()}/clipboardResult`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ success: success })
            });
            
            return success;
        };

        const showCopyFeedback = (format) => {
            copyMessage.value = `Copied: ${format}`;
            showCopyFlash.value = true;
            
            setTimeout(() => {
                showCopyFlash.value = false;
            }, 1500);
        };



        onMounted(() => {
            window.addEventListener('message', (event) => {
                const data = event.data;
                
                if (data.type === 'updateInfo' && data.info) {
                    Object.assign(entityInfo, data.info);
                    showNoEntity.value = false;
                } 
                else if (data.type === 'showUI') {
                    isVisible.value = data.show;
                } 
                else if (data.type === 'showNoEntity') {
                    showNoEntity.value = data.show;
                } 
                else if (data.type === 'copyFormat') {
                    copyFormattedInfo(data.format);
                } 
                else if (data.type === 'execCopy') {
                    execCopyToClipboard(data.text);
                    
                    let formatLabel;
                    switch(data.format) {
                        case 'model': formatLabel = 'Model Hash'; break;
                        case 'coords': formatLabel = 'Coordinates'; break;
                        case 'rotation': formatLabel = 'Rotation'; break;
                        case 'heading': formatLabel = 'Heading'; break;
                        case 'all': formatLabel = 'All Info'; break;
                        default: formatLabel = 'Text';
                    }
                    showCopyFeedback(formatLabel);
                }
            });
        });

        return {
            isVisible,
            showNoEntity,
            showCopyFlash,
            copyMessage,
            entityInfo,
            formatCoords,
            formatHeading,
            copyFormattedInfo
        };
    }
});

app.mount('#app');