            %check that the conversion above has worked:
            if length(pq) ~= nd
                disp('Number of edited depths wrong!!')
                %probably the wrong fill values in the field
                fv = nc{'Profparm'}.FillValue_(:);
                if fv < 0
                    ij = find(pp<-fv
                ij = find(pp>99.9 & pp < 100);
                if ~isempty(ij)
                    pq = nc{'ProfQP'}(c,:,1:nd,:,:,:);
                    nd2 = nd;
                    for dd = 1:length(ij)
                        if isempty(str2num(pq(ij(dd))))
                            pp(ij(dd)) = nc{'Profparm'}.FillValue_(:);
                            nd2 = nd2-1;
                        end
                    end
                    %now fix it:
                    nc{'Profparm'}(c,:,1:nd,:,:) = pp;
                    nc{'No_Depths'}(c) = nd2;
                    nd = nc{'No_Depths'}(c);
                    %re-read
                    pp = nc{'Profparm'}(c,:,1:nd,:,:);
                    pq = nc{'ProfQP'}(c,:,1:nd,:,:,:);
                    pq = str2num(pq);
                    if length(pq) ~= nd
                        ij = find(pp==0);
                        if ~isempty(ij)
                            dd = nc{'Depthpress'}(c,1:nd);
                            disp(['Found zeros from: ' num2str(range(ij)) ' out of ' num2str(length(pp)) ' points'])
                            disp(['Depths at zero temps: ' num2str(range(dd(ij)))])
                            nn = input('y to continue, N to stop','s');
                            if strmatch('y',nn)
                                pq = nc{'ProfQP'}(c,:,1:nd,:,:,:);
                                nd2 = nd;
                                for d = 1:length(ij)
                                    if isempty(str2num(pq(ij(d))))
                                        pp(ij(d)) =  nc{'Profparm'}.FillValue_(:);
                                        dd(ij(d)) =  nc{'Depthpress'}.FillValue_(:);
                                        nd2 = nd2-1;
                                    end
                                end
                                %now fix it:
                                nc{'Depthpress'}(c,1:nd) = dd;
                                nc{'Profparm'}(c,:,1:nd,:,:) = pp;
                                nc{'No_Depths'}(c) = nd2;
                                nd = nc{'No_Depths'}(c);
                                %re-read
                                pp = nc{'Profparm'}(c,:,1:nd,:,:);
                                pq = nc{'ProfQP'}(c,:,1:nd,:,:,:);
                                pq = str2num(pq);
                                if length(pq) ~= nd
                                    disp('Edited Still wrong!')
                                    return
                                end
                            else
                                disp('Stopping')
                                return
                            end
                        else
                            disp('Edited Still wrong, no zeros!')
                            return
                        end
                    end
                else
                    disp('Edited wrong, no 99.99s!')
                    return
                end
