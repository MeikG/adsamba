function createHome {
	# Set up variables.
	SUCCESS=""
	FAILPERM=""
	FAILSID=""
	FAILUSER=""

	while read USER; do
		# Check to see if they are in the ignore list.
		PREFIX="$USER@foobar.com"
		if ! grep -Fxq "$USER" $IGNORE; then

		# Process the folder.
		if [ ! -d "$MEDIA/$1/$USER" ]; then
			# Initialise the user into the idmap.
			wbinfo -i "$PREFIX"
			if [ $? -eq 0 ]; then
				wbUID=`id -u "$PREFIX"`
				# Copy the template folder with permissions and set them.
				cp -pr $MEDIA/$1/.template "$MEDIA/$1/$USER"
				setfacl -m u:$wbUID:rwx "$MEDIA/$1/$USER"
				chown -R foobar\\"$USER" "$MEDIA/$1/$USER"
				# Configure the account to have the specified quota.
				setquota -u "$PREFIX" "$QUOTA" "$QUOTA" 0 0 -a
				if [ $? -eq 0 ]; then
					# All good.
					grep -Fxq "$USER" $ADLIST && : || echo $USER>>$ADLIST
					SUCCESS=`[[ "$SUCCESS" == "" ]] && echo "$USER" || echo "$SUCCESS, $USER"`
				else
					# Either failed to copy the template folder, or set the permissions.
					rm -rf "$MEDIA/$1/$USER"
					grep -Fxq "$USER" $IGNORE && : || echo $USER>>$IGNORE
					FAILPERM=`[[ "$FAILPERM" == "" ]] && echo "$USER" || echo "$FAILPERM, $USER"`
				fi
			else
				# If we failed here, it's because the SID could not be converted into a UID.
				grep -Fxq "$USER" $IGNORE && : || echo $USER>>$IGNORE
				FAILSID=`[[ "$FAILSID" == "" ]] && echo "$USER" || echo "$FAILSID, $USER"`
			fi
		fi
	fi
	done <$TMPLIST

	if [ "$SUCCESS" == "" ] && [ "$FAILPERM" == "" ] && [ "$FAILSID" == "" ] && [ "$FAILUSER" == "" ] ; then
		echo "   -- Nothing to create in $MEDIA/$1" >> $LOGFILE
	else
		echo "   -- Processing $MEDIA/$1" >> $LOGFILE
	fi

	if [ "$SUCCESS" != "" ]; then
		echo "      -- Successful Home Areas Created:" >> $LOGFILE
		echo "         $SUCCESS" >> $LOGFILE
	fi

	if [ "$FAILPERM" != "" ]; then
		echo "      -- FAIL: Could not set permissions:" >> $LOGFILE
		echo "         $FAILPERM" >> $LOGFILE
	fi

	if [ "$FAILSID" != "" ]; then
		echo "      -- FAIL: Could not get user SID:" >> $LOGFILE
		echo "         $FAILSID" >> $LOGFILE
	fi

	if [ "$FAILUSER" != "" ]; then
		echo "      -- FAIL: Not a USER object:" >> $LOGFILE
		echo "         $FAILUSER" >> $LOGFILE
	fi

	return 0
}
